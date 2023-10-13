package ar.edu.itba.paw.webapp.controller;

import ar.edu.itba.paw.models.*;
import ar.edu.itba.paw.services.InstitutionService;
import ar.edu.itba.paw.services.SearchService;
import ar.edu.itba.paw.services.SecurityService;
import ar.edu.itba.paw.webapp.forms.SearchForm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import javax.validation.Valid;

import static ar.edu.itba.paw.webapp.controller.ControllerUtils.*;


@Controller
@RequestMapping("/search")
public class SearchController {
    private final InstitutionService institutionService;
    private final SearchService searchService;
    private final SecurityService securityService;

    @Autowired
    public SearchController(final InstitutionService institutionService, final SearchService searchService, final SecurityService securityService) {
        this.institutionService = institutionService;
        this.searchService = searchService;
        this.securityService = securityService;
    }

    @RequestMapping(method = RequestMethod.GET)
    public ModelAndView search(@Valid @ModelAttribute("searchForm") final SearchForm searchForm, final BindingResult result, final ModelMap model){
        if (result.hasErrors()) {
            return new ModelAndView("/errors/400");
        }

        final ModelAndView mav = new ModelAndView("search");

        Page<Searchable> pageResult = searchService.search(
                    searchForm.getInstitutionId(),
                    searchForm.getCareerId(),
                    searchForm.getSubjectId(),
                    searchForm.getCategory(),
                    searchForm.getWord(),
                    searchForm.getSortBy(),
                    searchForm.getAscending(),
                    searchForm.getPageNumber(),
                    searchForm.getPageSize()
        );

        mav.addObject("maxPage", pageResult.getTotalPages());
        mav.addObject("results", pageResult.getContent());
        mav.addObject(ADD_FAVORITE, model.getOrDefault(ADD_FAVORITE, false));
        mav.addObject(REMOVE_FAVORITE, model.getOrDefault(REMOVE_FAVORITE, false));
        InstitutionData institutionData = institutionService.getInstitutionData();

        mav.addObject("institutionData", toSafeJson(institutionData));
        return mav;
    }

    @ModelAttribute("user")
    public User getCurrentUser() {
        return this.securityService.getCurrentUser().orElse(null);
    }
}
