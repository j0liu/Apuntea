package ar.edu.itba.paw.persistence;import ar.edu.itba.paw.models.Category;import ar.edu.itba.paw.models.directory.Directory;import ar.edu.itba.paw.models.institutional.Subject;import ar.edu.itba.paw.models.note.Note;import ar.edu.itba.paw.models.user.User;import ar.edu.itba.paw.persistence.config.TestConfig;import org.junit.Before;import org.junit.Test;import org.junit.runner.RunWith;import org.springframework.beans.factory.annotation.Autowired;import org.springframework.jdbc.core.JdbcTemplate;import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;import org.springframework.jdbc.core.simple.SimpleJdbcInsert;import org.springframework.test.annotation.Rollback;import org.springframework.test.context.ContextConfiguration;import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;import org.springframework.test.jdbc.JdbcTestUtils;import org.springframework.transaction.annotation.Transactional;import static ar.edu.itba.paw.models.NameConstants.*;import static ar.edu.itba.paw.persistence.TestUtils.*;import javax.persistence.EntityManager;import javax.persistence.PersistenceContext;import javax.sql.DataSource;import java.util.*;import static org.junit.Assert.*;@Transactional@RunWith(SpringJUnit4ClassRunner.class)@ContextConfiguration(classes = TestConfig.class)@Rollbackpublic class DirectoryJpaDaoTest {    @PersistenceContext    private EntityManager em;    @Autowired    private DataSource ds;    @Autowired    private DirectoryJpaDao directoryDao;    private JdbcTemplate jdbcTemplate;    private NamedParameterJdbcTemplate namedParameterJdbcTemplate;    private User pepeUser;    private User saidmanUser;    private Directory privateDir;    @Before    public void setUp() {        jdbcTemplate = new JdbcTemplate(ds);        namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(ds);        pepeUser = em.find(User.class, PEPE_ID);        saidmanUser = em.find(User.class, SAIDMAN_ID);        privateDir = insertDirectory(em, new Directory.DirectoryBuilder()                        .name(PSVM)                        .parent(em.getReference(Directory.class,EDA_DIRECTORY_ID))                        .user(pepeUser)                        .visible(false)        );    }    @Test    public void testCreate() {        String name = "tempRoot";        UUID parentId = EDA_DIRECTORY_ID;        UUID userId = PEPE_ID;        boolean visible = true;        String color = "BBBBBB";        Directory directory = directoryDao.create(name, parentId, pepeUser, visible, color);        em.flush();        assertEquals(1, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + directory.getId() + "' AND directory_name = '" + name + "' AND parent_id = '" + parentId + "' AND user_id = '" + userId + "' AND visible = " + visible + " AND icon_color = '" + color + "'"));    }    @Test    public void testCreateRootDirectory() {        String name = "nuevaMateria";        Directory directory = directoryDao.createRootDirectory("nuevaMateria");        em.flush();        assertEquals(1, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + directory.getId() + "' AND directory_name = '"+ name +"' AND parent_id IS NULL AND user_id IS NULL"));    }    @Test    public void testGetDirectoryByIdPublic() {        String name = "public static void main";        Directory newDir = insertDirectory(em,                new Directory.DirectoryBuilder()                        .name(name)                        .parent(em.getReference(Directory.class, EDA_DIRECTORY_ID))                        .user(pepeUser)                        .visible(true)        );        Directory directory = directoryDao.getDirectoryById(newDir.getId(), SAIDMAN_ID).orElseThrow(AssertionError::new);        assertEquals(newDir.getId(), directory.getId());        assertEquals(name, directory.getName());    }    @Test    public void testGetDirectoryByIdNonExistent() {        Optional<Directory> maybeDirectory = directoryDao.getDirectoryById(UUID.randomUUID(), PEPE_ID);        assertFalse(maybeDirectory.isPresent());    }    @Test    public void testGetDirectoryByIdPrivate() {        Optional<Directory> maybeDirectory = directoryDao.getDirectoryById(privateDir.getId(), CARLADMIN_ID);        assertFalse(maybeDirectory.isPresent());    }    @Test    public void testGetDirectoryByIdPrivateOwner() {        Directory directory = directoryDao.getDirectoryById(privateDir.getId(), PEPE_ID).orElseThrow(AssertionError::new);        assertEquals(privateDir.getId(), directory.getId());        assertEquals(privateDir.getName(), directory.getName());    }    @Test    public void testDirectoryPathLength1() {        List<UUID> path = directoryDao.getDirectoryPathIds(EDA_DIRECTORY_ID);        assertEquals(EDA_DIRECTORY_ID, path.get(0));        assertEquals(1, path.size());    }    @Test    public void testDirectoryPathLength2() {        List<UUID> path = directoryDao.getDirectoryPathIds(GUIAS_DIRECTORY_ID);        assertEquals(2, path.size());        assertEquals(EDA_DIRECTORY_ID, path.get(0));        assertEquals(GUIAS_DIRECTORY_ID, path.get(1));    }    @Test    public void testDirectoryPathLength3() {        List<UUID> path = directoryDao.getDirectoryPathIds(MVC_DIRECTORY_ID);        assertEquals(3, path.size());        assertEquals(PAW_DIRECTORY_ID, path.get(0));        assertEquals(THEORY_DIRECTORY_ID, path.get(1));        assertEquals(MVC_DIRECTORY_ID, path.get(2));    }    @Test    public void testDirectoryPathLengthGreaterThan3() {        UUID[] directoryIds = new UUID[5];        insertDirectoryRec(5, 1, EDA_DIRECTORY_ID, directoryIds);        List<UUID> path = directoryDao.getDirectoryPathIds(directoryIds[4]);        assertEquals(6, path.size());        assertEquals(EDA_DIRECTORY_ID, path.get(0));        for (int i = 1; i < 6; i++)            assertEquals(directoryIds[i - 1], path.get(i));    }    private void insertDirectoryRec(final int maxLevel, final int currLevel, final UUID parentId, final UUID[] directoryIds)  {        if (currLevel > maxLevel) return;        Directory newDirId = insertDirectory(em, new Directory.DirectoryBuilder()                        .name("d" + currLevel)                        .parent(em.getReference(Directory.class, parentId))                        .user(pepeUser));        em.flush();        directoryIds[currLevel - 1] = newDirId.getId();        insertDirectoryRec(maxLevel, currLevel + 1, newDirId.getId(), directoryIds);    }    @Test    public void testDelete() {        int qtyBasuraPrev = JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_name LIKE " + "'%Basura%'");        directoryDao.delete(Collections.singletonList(BASURA_ID), PEPE_ID);        em.flush();        assertEquals(2, qtyBasuraPrev);        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_name LIKE " + "'%Basura%'"));    }    @Test    public void testDeleteMany() {        List<UUID> directoryIds = new ArrayList<>();        String[] names = {"tmp1", "tmp2", "tmp3", "tmp4"};        UUID parentId = jdbcInsertDirectory(namedParameterJdbcTemplate, "tmpParent", PEPE_ID, EDA_DIRECTORY_ID);        for (String name : names) {            UUID newDirId = jdbcInsertDirectory(namedParameterJdbcTemplate, name, PEPE_ID, parentId);            directoryIds.add(newDirId);        }        int countInserted = JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, DIRECTORIES, "user_id = '" + PEPE_ID + "' AND parent_id = '" + parentId + "'");        directoryDao.delete(directoryIds, PEPE_ID);        int countPostDelete = JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, DIRECTORIES, "user_id = '" + PEPE_ID + "' AND parent_id = '" + parentId + "'");        assertEquals(4, countInserted);        assertEquals(0, countPostDelete);    }    @Test    public void testUserTriesToDeleteDirectory() {        UUID newDirId = jdbcInsertDirectory(namedParameterJdbcTemplate, "temp", PEPE_ID, EDA_DIRECTORY_ID);        int countInserted = JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + newDirId + "'");        boolean success = directoryDao.delete(Collections.singletonList(newDirId), SAIDMAN_ID);        assertFalse(success);        assertEquals(1, countInserted);        assertEquals(1, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + newDirId + "'"));    }    @Test    public void testAdminDeletesDirectory() {        UUID newDirId = jdbcInsertDirectory(namedParameterJdbcTemplate, "temp", PEPE_ID, EDA_DIRECTORY_ID);        UUID newDirId2 = jdbcInsertDirectory(namedParameterJdbcTemplate, "temp2", PEPE_ID, EDA_DIRECTORY_ID);        UUID newDirId3 = jdbcInsertDirectory(namedParameterJdbcTemplate, "temp3", PEPE_ID, EDA_DIRECTORY_ID);        int countInserted = JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + newDirId + "' OR directory_id = '" + newDirId2 + "' OR directory_id = '" + newDirId3 + "'");        List<UUID> ids = new ArrayList<>();        ids.add(newDirId);        ids.add(newDirId2);        ids.add(newDirId3);        boolean success = directoryDao.delete(ids);        assertTrue(success);        assertEquals(3, countInserted);        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + newDirId + "'"));        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + newDirId2 + "'"));        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + newDirId3 + "'"));    }    @Test    public void testDeleteRootDirectorySuccess() {        UUID rootDirectoryId = jdbcInsertDirectory(namedParameterJdbcTemplate, "root", null, null);        UUID root2DirectoryId = jdbcInsertDirectory(namedParameterJdbcTemplate, "root2", null, null);        int countInserted = JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + rootDirectoryId + "'");        boolean success = directoryDao.delete(Collections.singletonList(rootDirectoryId));        assertTrue(success);        assertEquals(1, countInserted);        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + rootDirectoryId + "'"));        assertEquals(1, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directories", "directory_id = '" + root2DirectoryId + "'"));    }    @Test    public void testDeleteDirectoryNonExistent() {        UUID id = UUID.randomUUID();        boolean success = directoryDao.delete(Collections.singletonList(id));        assertFalse(success);    }    @Test    public void testAddFavorite() {        directoryDao.addFavorite(em.getReference(User.class, PEPE_ID), EDA_DIRECTORY_ID);        em.flush();        assertEquals(1, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directory_Favorites", "user_id = '" + PEPE_ID + "' AND directory_id = '" + EDA_DIRECTORY_ID + "'"));        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directory_Favorites", "user_id = '" + SAIDMAN_ID + "' AND directory_id = '" + EDA_DIRECTORY_ID + "'"));    }    @Test    public void testRemoveFavorite() {        Directory newDir = insertDirectory(em, new Directory.DirectoryBuilder().name("temp")                .parent(em.getReference(Directory.class, EDA_DIRECTORY_ID))                .user(pepeUser)        );        insertFavoriteDirectory(em, newDir.getId(), PEPE_ID);        insertFavoriteDirectory(em, newDir.getId(), SAIDMAN_ID);        directoryDao.removeFavorite(em.getReference(User.class, PEPE_ID), newDir.getId());        em.flush();        assertEquals(0, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directory_Favorites", "user_id = '" + PEPE_ID + "' AND directory_id = '" + newDir.getId() + "'"));        assertEquals(1, JdbcTestUtils.countRowsInTableWhere(jdbcTemplate, "Directory_Favorites", "user_id = '" + SAIDMAN_ID + "' AND directory_id = '" + newDir.getId() + "'"));    }    @Test    public void testCountRootDirQuantity() {        Directory edaDir = em.find(Directory.class, EDA_DIRECTORY_ID);        Note.NoteBuilder nb = new Note.NoteBuilder().category(Category.EXAM).fileType(".jpg").parentId(EDA_DIRECTORY_ID).subject(em.getReference(Subject.class, EDA_ID)).user(pepeUser).visible(true);        insertNote(em, nb.name("temp").parentId(EDA_DIRECTORY_ID).user(pepeUser).visible(false));        insertNote(em, nb.name("temp").parentId(EDA_DIRECTORY_ID).user(saidmanUser).visible(true));        directoryDao.setRootDirsFileQuantity(Collections.singletonList(EDA_DIRECTORY_ID), PEPE_ID, PEPE_ID);        assertEquals(3, edaDir.getQtyFiles()); // 2 previously loaded notes + newNoteP    }    @Test    public void testPrivateDoesNotCountInQuantity() {        Directory edaDir = em.find(Directory.class, EDA_DIRECTORY_ID);        Note.NoteBuilder nb = new Note.NoteBuilder().category(Category.EXAM).fileType(".jpg").parentId(EDA_DIRECTORY_ID).subject(em.getReference(Subject.class, EDA_ID)).user(pepeUser).visible(true);        insertNote(em, nb.name("temp").parentId(EDA_DIRECTORY_ID).user(pepeUser).visible(false));        insertNote(em, nb.name("temp").parentId(EDA_DIRECTORY_ID).user(saidmanUser).visible(true));        directoryDao.setRootDirsFileQuantity(Collections.singletonList(EDA_DIRECTORY_ID), PEPE_ID, SAIDMAN_ID);        assertEquals(2, edaDir.getQtyFiles()); // only the 2 previously loaded notes    }}