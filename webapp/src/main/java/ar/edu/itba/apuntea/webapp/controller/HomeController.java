package ar.edu.itba.apuntea.webapp.controller;

import ar.edu.itba.apuntea.models.Note;
import ar.edu.itba.apuntea.services.DataService;
import ar.edu.itba.apuntea.services.NoteService;
import ar.edu.itba.apuntea.webapp.forms.CreateNoteForm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import javax.validation.Valid;

@Controller
public class HomeController {

    private final DataService dataService;

    @Autowired
    public HomeController(final DataService dataService) {
        this.dataService = dataService;
    }

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public ModelAndView index(@ModelAttribute("createNoteForm") final CreateNoteForm createNoteForm) {
        ModelAndView mav = new ModelAndView("index");
        mav.addObject("institutions", dataService.getInstitutions());
        mav.addObject("careers", dataService.getCareers());
        mav.addObject("subjects", dataService.getSubjects());

        return mav;
    }

    @RequestMapping(value = "/create" ,method = RequestMethod.POST)
    public ModelAndView createNote(@Valid @ModelAttribute final CreateNoteForm createNoteForm, final BindingResult result)
    {
        if(result.hasErrors()) {
            ModelAndView modelAndView = new ModelAndView("index");
            modelAndView.addObject("errors", result.getAllErrors());
            return modelAndView;
        }

        Note note = dataService.createNote(createNoteForm.getFile(), createNoteForm.getName());
        return new ModelAndView("redirect:/notes/" + note.getNoteId());
    }

}
