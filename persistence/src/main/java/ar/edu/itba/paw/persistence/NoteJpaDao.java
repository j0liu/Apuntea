package ar.edu.itba.paw.persistence;

import ar.edu.itba.paw.models.Category;
import ar.edu.itba.paw.models.directory.Directory;
import ar.edu.itba.paw.models.directory.DirectoryFavorite;
import ar.edu.itba.paw.models.institutional.Subject;
import ar.edu.itba.paw.models.note.NoteFavorite;
import ar.edu.itba.paw.models.search.SearchArguments;
import ar.edu.itba.paw.models.note.Note;
import ar.edu.itba.paw.models.note.NoteFile;
import ar.edu.itba.paw.models.note.Review;
import ar.edu.itba.paw.models.search.SortArguments;
import ar.edu.itba.paw.models.user.User;
import org.springframework.stereotype.Repository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.math.BigInteger;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Repository
public class NoteJpaDao implements NoteDao {
    @PersistenceContext
    private EntityManager em;

    private final Logger LOGGER = LoggerFactory.getLogger(NoteJpaDao.class);
    /*package-private*/ static final int REVIEW_LIMIT = 10;

    @Override
    public UUID create(String name, UUID subjectId, User user, UUID parentId, boolean visible, byte[] file, String category, String fileType) {
        Note note = new Note.NoteBuilder()
                .name(name)
                .subject(em.getReference(Subject.class, subjectId))
                .parentId(parentId)
                .user(user)
                .visible(visible)
                .category(Category.valueOf(category.toUpperCase()))
                .fileType(fileType)
                .lastModifiedAt(LocalDateTime.now())
                .build();

        em.persist(note);
        NoteFile noteFile = new NoteFile(file, note);
        em.persist(noteFile);
        return note.getId();
    }

    @Override
    public Optional<Note> getNoteById(UUID noteId, UUID currentUserId) {
        return em.createQuery("SELECT n FROM Note n WHERE n.id = :noteId AND (n.visible = true OR n.user.id = :currentUserId)", Note.class)
                .setParameter("noteId", noteId)
                .setParameter("currentUserId", currentUserId)
                .getResultList()
                .stream()
                .findFirst();
    }

    @Override
    public Optional<NoteFile> getNoteFileById(UUID noteId, UUID currentUserId){
        return em.createQuery("SELECT nf FROM NoteFile nf WHERE nf.note.id = :noteId AND (nf.note.visible = true OR nf.note.user.id = :currentUserId)", NoteFile.class)
                .setParameter("noteId", noteId)
                .setParameter("currentUserId", currentUserId)
                .getResultList()
                .stream()
                .findFirst();
    }


    @Override
    public boolean delete(List<UUID> noteIds) {
        if (noteIds.isEmpty()) return false;
        return em.createQuery("DELETE FROM Note n WHERE n.id IN :noteIds")
                .setParameter("noteIds", noteIds)
                .executeUpdate() == noteIds.size();
    }

    @Override
    public boolean delete(List<UUID> noteIds, UUID currentUserId) {
        if (noteIds.isEmpty()) return false;
        return em.createQuery("DELETE FROM Note n WHERE n.id IN :noteIds AND n.user.id = :currentUserId")
                .setParameter("noteIds", noteIds)
                .setParameter("currentUserId", currentUserId)
                .executeUpdate() == noteIds.size();
    }

    @Override
    public Review getReview(UUID noteId, UUID userId)  {
        return em.createQuery("FROM Review r WHERE r.note.id = :noteId AND r.user.id = :userId", Review.class)
                .setParameter("noteId", noteId)
                .setParameter("userId", userId)
                .getSingleResult();
    }

    @Override
    public int countReviews(UUID noteId) {
        return ((BigInteger)em.createNativeQuery("SELECT COUNT(*) FROM Reviews WHERE note_id = :noteId")
                .setParameter("noteId", noteId)
                .getSingleResult()).intValue();
    }

    @Override
    public List<Review> getReviews(UUID noteId, int pageNum) {
        return getReviews(noteId, pageNum, REVIEW_LIMIT);
    }

    @Override
    public List<Review> getReviews(UUID noteId, int pageNum, int pageSize) {
        @SuppressWarnings("unchecked")
        List<UUID> userIDs = (List<UUID>) (em.createNativeQuery("SELECT CAST(user_id AS VARCHAR(36)) FROM Reviews WHERE note_id = :noteId ORDER BY created_at DESC")
                .setParameter("noteId", noteId)
                .setFirstResult((pageNum - 1) * pageSize)
                .setMaxResults(pageSize)
                .getResultList())
                .stream().map(o -> UUID.fromString((String) o)).collect(Collectors.toList());
        if (userIDs.isEmpty()) return Collections.emptyList();
        return em.createQuery("FROM Review r WHERE r.note.id = :noteId AND r.user.id IN :userIDs ORDER BY r.createdAt DESC", Review.class)
                .setParameter("noteId", noteId)
                .setParameter("userIDs", userIDs)
                .getResultList();
    }

    @Override
    public List<Review> getFirstReviews(UUID noteId, UUID currentUserId) {
        // Right now it's not necessary to validate that the current user has visibility enabled
        @SuppressWarnings("unchecked")
        List<UUID> userIDs = ((List<Object[]>)em.createNativeQuery("SELECT CAST(user_id AS VARCHAR(36)), (user_id = :currentUserId) as isCurrent FROM Reviews WHERE note_id = :noteId ORDER BY isCurrent DESC, created_at DESC")
                .setParameter("noteId", noteId)
                .setParameter("currentUserId", currentUserId)
                .setMaxResults(REVIEW_LIMIT)
                .getResultList())
                .stream().map(o -> UUID.fromString((String) o[0])).collect(Collectors.toList());
        if (userIDs.isEmpty()) return Collections.emptyList();
        return em.createQuery("SELECT r, (r.user.id = :currentUserId) as isCurrent FROM Review r WHERE r.note.id = :noteId AND r.user.id IN :userIDs ORDER BY isCurrent DESC, r.createdAt DESC", Object[].class)
                .setParameter("noteId", noteId)
                .setParameter("currentUserId", currentUserId)
                .setParameter("userIDs", userIDs)
                .getResultList().stream().map(o -> (Review) o[0]).collect(Collectors.toList());
    }

    @Override
    public Review createOrUpdateReview(Note note, User user, int score, String content) {
        Review review = new Review(note, user, score, content);
        em.merge(review);
        return review;
    }

    @Override
    public boolean deleteReview(UUID noteId, UUID userId) {
        return em.createQuery("DELETE FROM Review r WHERE r.note.id = :noteId AND r.user.id = :userId")
                .setParameter("noteId", noteId)
                .setParameter("userId", userId)
                .executeUpdate() == 1;
    }


    @Override
    public List<Note> getFavorites(UUID userId) {
        return em.createQuery("SELECT n FROM NoteFavorite f JOIN f.note n LEFT JOIN n.user u WHERE f.user.id = :userId AND (n.visible = true OR u.id = :userId)", Note.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    @Override
    public void addFavorite(UUID userId, UUID noteId) {
        NoteFavorite fav = new NoteFavorite(em.getReference(User.class, userId), em.getReference(Note.class, noteId));
        em.persist(fav);
    }

    @Override
    public boolean removeFavorite(UUID userId, UUID noteId) {
        return em.createQuery("DELETE FROM NoteFavorite f WHERE f.user.id = :userId AND f.note.id = :noteId")
                .setParameter("userId", userId)
                .setParameter("noteId", noteId)
                .executeUpdate() == 1;
    }


    @Override
    public List<Note> findNoteByIds(List<UUID> noteIds, UUID currentUserId, SortArguments sa) {
        if (noteIds.isEmpty()) return Collections.emptyList();
        List<Note> notes = em.createQuery(String.format("SELECT n FROM Note n JOIN n.user u WHERE n.id IN :noteIds ORDER BY n.%s %s", JdbcDaoUtils.SORTBY_CAMELCASE.getOrDefault(sa.getSortBy(), "avgScore"), sa.isAscending()? "" : "DESC"), Note.class)
                .setParameter("noteIds", noteIds)
                .getResultList();

        if (currentUserId != null) {
            List<Note> favorites = em.createQuery("SELECT f.note FROM NoteFavorite f WHERE f.user.id = :userId AND f.note.id IN :noteIds", Note.class)
                    .setParameter("userId", currentUserId)
                    .setParameter("noteIds", noteIds)
                    .getResultList();
            favorites.forEach(note -> note.setFavorite(true));
        }
        return notes;
    }

    @Override
    public List<Note> findNoteByIds(List<UUID> noteIds) {
        return findNoteByIds(noteIds, null, new SortArguments(SortArguments.SortBy.DATE, true));
    }

}
