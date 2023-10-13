package ar.edu.itba.paw.services;

import ar.edu.itba.paw.models.Subject;
import ar.edu.itba.paw.models.exceptions.InvalidDirectoryException;
import ar.edu.itba.paw.models.exceptions.InvalidSubjectCareerException;
import ar.edu.itba.paw.models.exceptions.InvalidSubjectException;
import ar.edu.itba.paw.persistence.CareerDao;
import ar.edu.itba.paw.persistence.DirectoryDao;
import ar.edu.itba.paw.persistence.SearchDao;
import ar.edu.itba.paw.persistence.SubjectDao;
import static org.junit.Assert.*;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import static org.mockito.Mockito.*;
import org.mockito.junit.MockitoJUnitRunner;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RunWith(MockitoJUnitRunner.class)
public class SubjectServiceImplTest {
    @Mock
    private SubjectDao subjectDao;
    @Mock
    private CareerDao careerDao;
    @Mock
    private DirectoryDao directoryDao;
    @Mock
    private SearchDao searchDao;

    @InjectMocks
    private SubjectServiceImpl subjectService;

    @Test
    public void testGetSubjectsGroupByYear() {
        Mockito.when(subjectDao.getSubjectsByCareerId(Mockito.any())).thenReturn(Stream.of(
                new Subject(UUID.randomUUID(), "Subject 1a", UUID.randomUUID(), 1),
                new Subject(UUID.randomUUID(), "Subject 1b", UUID.randomUUID(), 1),
                new Subject(UUID.randomUUID(), "Subject 1c", UUID.randomUUID(), 1),
                new Subject(UUID.randomUUID(), "Subject 2", UUID.randomUUID(), 2),
                new Subject(UUID.randomUUID(), "Subject 3a", UUID.randomUUID(), 3),
                new Subject(UUID.randomUUID(), "Subject 3b", UUID.randomUUID(), 3)
        ).collect(Collectors.toList()));

        Map<Integer, List<Subject>> subjectsMap =  subjectService.getSubjectsByCareerGroupByYear(UUID.randomUUID());

        assertEquals(3, subjectsMap.size());
        assertEquals(3, subjectsMap.get(1).size());
        assertEquals(1, subjectsMap.get(2).size());
        assertEquals(2, subjectsMap.get(3).size());
        assertTrue(subjectsMap.keySet()
                              .stream()
                              .allMatch(year -> subjectsMap.get(year)
                                                           .stream()
                                                           .allMatch(subject -> subject.getYear()
                                                                                       .equals(year))));
    }

    @Test
    public void testUnlinkSubjectFromCareerSuccessNoChildren() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.of(new Subject(subjectId, "Subject 1a", directoryId))
        );
        Mockito.when(subjectDao.unlinkSubjectFromCareer(Mockito.any(), Mockito.any())).thenReturn(true);
        Mockito.when(careerDao.countCareersBySubjectId(Mockito.any())).thenReturn(5);
        subjectService.unlinkSubjectFromCareer(subjectId, careerId);

        InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
        inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
        inOrder.verify(subjectDao, times(1)).unlinkSubjectFromCareer(subjectId, careerId);
        inOrder.verify(careerDao, times(1)).countCareersBySubjectId(subjectId);
        inOrder.verify(searchDao, times(0)).countChildren(directoryId);
        inOrder.verify(subjectDao, times(0)).delete(subjectId);
        inOrder.verify(directoryDao, times(0)).deleteRootDirectory(directoryId);
    }

    @Test
    public void testUnlinkSubjectFromCareerSuccessNoCareers() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.of(new Subject(subjectId, "Subject 1a", directoryId))
        );
        Mockito.when(subjectDao.unlinkSubjectFromCareer(Mockito.any(), Mockito.any())).thenReturn(true);
        Mockito.when(careerDao.countCareersBySubjectId(Mockito.any())).thenReturn(0);
        Mockito.when(searchDao.countChildren(Mockito.any())).thenReturn(1);

        subjectService.unlinkSubjectFromCareer(subjectId, careerId);

        InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
        inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
        inOrder.verify(subjectDao, times(1)).unlinkSubjectFromCareer(subjectId, careerId);
        inOrder.verify(careerDao, times(1)).countCareersBySubjectId(subjectId);
        inOrder.verify(searchDao, times(1)).countChildren(directoryId);
        inOrder.verify(subjectDao, times(0)).delete(subjectId);
        inOrder.verify(directoryDao, times(0)).deleteRootDirectory(directoryId);
    }

    @Test(expected = InvalidSubjectException.class)
    public void testUnlinkSubjectFromCareerFailureGetSubjectById() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.empty()
        );

        try {
            subjectService.unlinkSubjectFromCareer(subjectId, careerId);
        } catch (InvalidSubjectException e) {
            InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
            inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
            inOrder.verify(subjectDao, times(0)).unlinkSubjectFromCareer(subjectId, careerId);
            inOrder.verify(careerDao, times(0)).countCareersBySubjectId(subjectId);
            inOrder.verify(searchDao, times(0)).countChildren(directoryId);
            inOrder.verify(subjectDao, times(0)).delete(subjectId);
            inOrder.verify(directoryDao, times(0)).deleteRootDirectory(directoryId);
            throw e;
        }
    }

    @Test(expected = InvalidSubjectCareerException.class)
    public void testUnlinkSubjectFromCareerFailureUnlinkSubject() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.of(new Subject(subjectId, "Subject 1a", directoryId))
        );
        Mockito.when(subjectDao.unlinkSubjectFromCareer(Mockito.any(), Mockito.any())).thenReturn(false);

        try {
            subjectService.unlinkSubjectFromCareer(subjectId, careerId);
        } catch (InvalidSubjectCareerException e) {
            InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
            inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
            inOrder.verify(subjectDao, times(1)).unlinkSubjectFromCareer(subjectId, careerId);
            inOrder.verify(careerDao, times(0)).countCareersBySubjectId(subjectId);
            inOrder.verify(searchDao, times(0)).countChildren(directoryId);
            inOrder.verify(subjectDao, times(0)).delete(subjectId);
            inOrder.verify(directoryDao, times(0)).deleteRootDirectory(directoryId);
            throw e;
        }
    }

    @Test
    public void testUnlinkSubjectFromCareerDeletionSuccess() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.of(new Subject(subjectId, "Subject 1a", directoryId))
        );
        Mockito.when(subjectDao.unlinkSubjectFromCareer(Mockito.any(), Mockito.any())).thenReturn(true);
        Mockito.when(careerDao.countCareersBySubjectId(Mockito.any())).thenReturn(0);
        Mockito.when(searchDao.countChildren(Mockito.any())).thenReturn(0);
        Mockito.when(subjectDao.delete(Mockito.any())).thenReturn(true);
        Mockito.when(directoryDao.deleteRootDirectory(Mockito.any())).thenReturn(true);

        subjectService.unlinkSubjectFromCareer(subjectId, careerId);

        InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
        inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
        inOrder.verify(subjectDao, times(1)).unlinkSubjectFromCareer(subjectId, careerId);
        inOrder.verify(careerDao, times(1)).countCareersBySubjectId(subjectId);
        inOrder.verify(searchDao, times(1)).countChildren(directoryId);
        inOrder.verify(subjectDao, times(1)).delete(subjectId);
        inOrder.verify(directoryDao, times(1)).deleteRootDirectory(directoryId);
    }

    @Test(expected = InvalidSubjectException.class)
    public void testUnlinkSubjectFromCareerDeletionFailureDeleteSubject() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.of(new Subject(subjectId, "Subject 1a", directoryId))
        );
        Mockito.when(subjectDao.unlinkSubjectFromCareer(Mockito.any(), Mockito.any())).thenReturn(true);
        Mockito.when(careerDao.countCareersBySubjectId(Mockito.any())).thenReturn(0);
        Mockito.when(searchDao.countChildren(Mockito.any())).thenReturn(0);
        Mockito.when(subjectDao.delete(Mockito.any())).thenReturn(false);
        try {
            subjectService.unlinkSubjectFromCareer(subjectId, careerId);
        } catch (InvalidSubjectException e) {
            InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
            inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
            inOrder.verify(subjectDao, times(1)).unlinkSubjectFromCareer(subjectId, careerId);
            inOrder.verify(careerDao, times(1)).countCareersBySubjectId(subjectId);
            inOrder.verify(searchDao, times(1)).countChildren(directoryId);
            inOrder.verify(subjectDao, times(1)).delete(subjectId);
            inOrder.verify(directoryDao, times(0)).deleteRootDirectory(directoryId);
            throw e;
        }
    }

    @Test(expected = InvalidDirectoryException.class)
    public void testUnlinkSubjectFromCareerDeletionFailureDeleteRootDirectory() {
        UUID subjectId = UUID.randomUUID();
        UUID directoryId = UUID.randomUUID();
        UUID careerId = UUID.randomUUID();
        Mockito.when(subjectDao.getSubjectById(subjectId)).thenReturn(
                Optional.of(new Subject(subjectId, "Subject 1a", directoryId))
        );
        Mockito.when(subjectDao.unlinkSubjectFromCareer(Mockito.any(), Mockito.any())).thenReturn(true);
        Mockito.when(careerDao.countCareersBySubjectId(Mockito.any())).thenReturn(0);
        Mockito.when(searchDao.countChildren(Mockito.any())).thenReturn(0);
        Mockito.when(subjectDao.delete(Mockito.any())).thenReturn(true);
        Mockito.when(directoryDao.deleteRootDirectory(Mockito.any())).thenReturn(false);
        try {
            subjectService.unlinkSubjectFromCareer(subjectId, careerId);
        } catch (InvalidDirectoryException e) {
            InOrder inOrder = Mockito.inOrder(subjectDao, careerDao, directoryDao, searchDao);
            inOrder.verify(subjectDao, times(1)).getSubjectById(subjectId);
            inOrder.verify(subjectDao, times(1)).unlinkSubjectFromCareer(subjectId, careerId);
            inOrder.verify(careerDao, times(1)).countCareersBySubjectId(subjectId);
            inOrder.verify(searchDao, times(1)).countChildren(directoryId);
            inOrder.verify(subjectDao, times(1)).delete(subjectId);
            inOrder.verify(directoryDao, times(1)).deleteRootDirectory(directoryId);
            throw e;
        }
    }

}
