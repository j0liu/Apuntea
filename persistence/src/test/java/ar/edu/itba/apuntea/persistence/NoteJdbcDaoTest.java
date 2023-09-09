package ar.edu.itba.apuntea.persistence;

import ar.edu.itba.apuntea.models.Category;
import ar.edu.itba.apuntea.models.Note;
import ar.edu.itba.apuntea.models.SearchArguments;
import ar.edu.itba.apuntea.persistence.config.TestConfig;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.jdbc.JdbcTestUtils;

import javax.sql.DataSource;

import java.util.List;
import static org.junit.Assert.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = TestConfig.class)

public class NoteJdbcDaoTest {
    @Autowired
    private DataSource ds;
    @Autowired
    private NoteDao noteDao;
    private JdbcTemplate jdbcTemplate;

    private static String ITBA_ID = "10000000-0000-0000-0000-000000000000";
    private static String ING_INF = "c0000000-0000-0000-0000-000000000000";
    private static String EDA_ID = "50000000-0000-0000-0000-000000000000";

    @Before
    public void setUp() {
        jdbcTemplate = new JdbcTemplate(ds);
    }

    @Test
    public void testSearchByInstitution() {
        SearchArguments sa = new SearchArguments(ITBA_ID, null, null, null, null);
        List<Note> notes = noteDao.search(sa);
        assertEquals(5, notes.size());
    }

    @Test
    public void testSearchByCareer(){
        SearchArguments sa = new SearchArguments(ITBA_ID, ING_INF, null, null, null);
        List<Note> notes = noteDao.search(sa);
        assertEquals(3, notes.size());
    }

    @Test
    public void testBySubject(){
        SearchArguments sa = new SearchArguments(ITBA_ID, ING_INF, EDA_ID, null, null);
        List<Note> notes = noteDao.search(sa);
        assertEquals(3, notes.size());
    }
    @Test
    public void testByCategory(){
        SearchArguments sa = new SearchArguments(ITBA_ID, ING_INF, EDA_ID, Category.PRACTICE.toString(), null);
        List<Note> notes = noteDao.search(sa);
        assertEquals(1, notes.size());
    }

    @Test
    public void testOrderBy(){
        SearchArguments sa = new SearchArguments(null, null, null, null, null, "name", true, 1, 10);
        List<Note> notes = noteDao.search(sa);
        for (int i = 0; i < notes.size() - 2; i++) {
            assertTrue(notes.get(i).getName().toUpperCase().compareTo(notes.get(i + 1).getName().toUpperCase()) <= 0);
        }
    }

    @Test
    public void testByScore() {
        SearchArguments sa = new SearchArguments(null, null, null, null, 3.0f);
        List<Note> notes = noteDao.search(sa);
        assertEquals(2, notes.size());
        notes.forEach(note -> assertTrue(note.getAvgScore().get() >= 3.0f));
    }

    @Test
    public void testByPage() {
        SearchArguments sa = new SearchArguments(null, null, null, null, null, null, true, 1, 2);
        List<Note> notes = noteDao.search(sa);
        assertEquals(2, notes.size());
    }
}
