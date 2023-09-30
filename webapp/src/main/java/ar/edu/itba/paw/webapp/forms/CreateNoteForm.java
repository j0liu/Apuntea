package ar.edu.itba.paw.webapp.forms;

import ar.edu.itba.paw.webapp.validation.MaxFileSize;
import ar.edu.itba.paw.webapp.validation.ValidFileName;
import org.hibernate.validator.constraints.NotEmpty;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.constraints.*;


public class CreateNoteForm extends CreateSearchableForm {

    @ValidFileName(allowedExtensions = {".pdf"}) // TODO: Add more extensions
    @MaxFileSize(megabytes = 500)
    private MultipartFile file;
    @NotEmpty
    @Pattern(regexp = "theory|practice|exam|other")
    private String category;
    private boolean visible = true;

    public MultipartFile getFile() {
        return file;
    }

    public String getCategory() {
        return category;
    }

    public void setFile(MultipartFile file) {
        this.file = file;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Boolean getVisible() {
        return visible;
    }

    public void setVisible(Boolean visible) {
        this.visible = visible;
    }

}
