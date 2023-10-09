package ar.edu.itba.paw.persistence;

import ar.edu.itba.paw.models.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.simple.SimpleJdbcInsert;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import static ar.edu.itba.paw.persistence.JdbcDaoUtils.*;

import javax.sql.DataSource;
import java.util.*;

@Repository
class UserJdbcDao implements UserDao{
    private final JdbcTemplate jdbcTemplate;
    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
    private final SimpleJdbcInsert jdbcRoleInsert;

    private static final RowMapper<User> ROW_MAPPER = (rs, rowNum)  ->
            new User(
                    UUID.fromString(rs.getString(USER_ID)),
                    rs.getString(FIRST_NAME),
                    rs.getString(LAST_NAME),
                    rs.getString(USERNAME),
                    rs.getString(EMAIL),
                    rs.getString(PASSWORD),
                    (String[]) rs.getArray(ROLES).getArray(),
                    rs.getString(LOCALE),
                    new Institution(
                            UUID.fromString(rs.getString(INSTITUTION_ID)),
                            rs.getString(INSTITUTION_NAME)
                    ),
                    new Career(
                            UUID.fromString(rs.getString(CAREER_ID)),
                            rs.getString(CAREER_NAME)
                    )
            );

    private static final RowMapper<ProfilePicture> PROFILE_IMAGE_ROW_MAPPER = (rs, rowNum) -> new ProfilePicture(rs.getString(USER_ID), rs.getObject(IMAGE));


    @Autowired
    public UserJdbcDao(final DataSource ds){
        this.jdbcTemplate = new JdbcTemplate(ds);
        this.jdbcRoleInsert = new SimpleJdbcInsert(ds)
                .withTableName(USER_ROLES);
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(ds);
    }

    // TODO: Make transactional in 3rd sprint
//    @Transactional
    @Override
    public void create(final String email, final String password, final UUID careerId, final String lang, final Role role){
        final MapSqlParameterSource args = new MapSqlParameterSource();
        args.addValue(EMAIL, email);
        args.addValue(PASSWORD, password);
        args.addValue(CAREER_ID, careerId);
        args.addValue(LOCALE, lang);

        KeyHolder holder = new GeneratedKeyHolder();

        // TODO: See if we can remove the try catch for the last sprint
        try {
            namedParameterJdbcTemplate.update("INSERT INTO users (email, password, career_id, locale) VALUES (:email, :password, :career_id, :locale)",
                    args, holder, new String[]{USER_ID} );
        } catch (DuplicateKeyException e) {
            int rows = namedParameterJdbcTemplate.update("UPDATE users SET password = :password, career_id = :career_id, locale = :locale WHERE email = :email AND password IS NULL",
                    args, holder, new String[]{USER_ID} );
            if (rows == 0) throw e;
        }

        final Map<String, Object> roleArgs = new HashMap<>();
        roleArgs.put(USER_ID, holder.getKeys().get(USER_ID));
        roleArgs.put(ROLE_NAME, role.getRole());
        jdbcRoleInsert.execute(roleArgs);
    }

    @Override
    public Optional<User> findByEmail(String email) {
            return jdbcTemplate.query("SELECT u.*, array_agg(r.role_name) as roles, i.institution_id, i.institution_name, c.career_id, c.career_name FROM users u " +
                    "INNER JOIN User_Roles r ON u.user_id = r.user_id " +
                    "INNER JOIN Careers c ON u.career_id = c.career_id " +
                    "INNER JOIN Institutions i ON c.institution_id = i.institution_id " +
                    "WHERE u.email = ? " +
                    "GROUP BY u.user_id, c.career_id, i.institution_id", ROW_MAPPER, email).stream().findFirst();
    }

    @Override
    public Optional<User> findByUsername(String username) {
        return jdbcTemplate.query("SELECT u.*, array_agg(r.role_name) as roles, i.institution_id, i.institution_name, c.career_id, c.career_name FROM users u " +
                "INNER JOIN User_Roles r ON u.user_id = r.user_id " +
                "INNER JOIN Careers c ON u.career_id = c.career_id " +
                "INNER JOIN Institutions i ON c.institution_id = i.institution_id " +
                "WHERE u.username = ? " +
                "GROUP BY u.user_id, c.career_id, i.institution_id", ROW_MAPPER, username).stream().findFirst();
    }

    @Override
    public boolean update(User user) {
        return jdbcTemplate.update("UPDATE Users SET first_name = ?, last_name = ?, username = ? WHERE user_id = ?",
                user.getFirstName(), user.getLastName(), user.getUsername(), user.getUserId()) == 1;
    }

    @Override
    public Optional<ProfilePicture> getProfilePicture(UUID userId){
        return jdbcTemplate.query("SELECT user_id, image FROM Users u LEFT JOIN Images i ON u.profile_picture_id = i.image_id WHERE user_id = ?",
                    PROFILE_IMAGE_ROW_MAPPER, userId).stream().findFirst();
    }

    @Transactional
    @Override
    public void updateProfilePicture(UUID userId, byte[] profilePicture) {
        final MapSqlParameterSource args = new MapSqlParameterSource();
        args.addValue(USER_ID, userId);
        args.addValue(IMAGE, profilePicture);
        KeyHolder holder = new GeneratedKeyHolder();
        jdbcTemplate.update("DELETE FROM Images WHERE image_id = (SELECT profile_picture_id FROM Users WHERE user_id = ?)", userId);
        namedParameterJdbcTemplate.update("INSERT INTO Images (image) VALUES (:image)", args, holder, new String[]{IMAGE_ID});
        jdbcTemplate.update("UPDATE Users SET profile_picture_id = ? WHERE user_id = ?", holder.getKeys().get(IMAGE_ID), userId);
    }

    @Override
    public void updatePassword(UUID userId, String password) {
        jdbcTemplate.update("UPDATE Users SET password = ? WHERE user_id = ?", password, userId);
    }

    @Override
    public boolean updatePasswordForUserWithEmail(String email, String password) {
        return jdbcTemplate.update("UPDATE Users SET password = ? WHERE email = ?", password, email) == 1;
    }
}
