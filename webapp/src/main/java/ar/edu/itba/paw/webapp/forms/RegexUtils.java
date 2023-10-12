package ar.edu.itba.paw.webapp.forms;

public class RegexUtils {

    public static final String FILE_REGEX = "^(?!([ ,\\-_0-9.]+)$)[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ,\\-_]+$";

    public static final String PASSWORD_REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).+$";

    public static final String USERNAME_REGEX = "^(?![\\-._]+$)(?!^\\d+$)[a-zA-Z0-9.\\-_]+$";

    public static final String NAME_REGEX = "([a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]+[ ]?)*";

    public static final String EMAIL_REGEX = "^(?=.{1,64}@)[A-Za-z0-9\\+_-]+(\\.[A-Za-z0-9\\+_-]+)*@[^-][A-Za-z0-9\\+-]+(\\.[A-Za-z0-9\\+-]+)*(\\.[A-Za-z]{2,})$";

    public static final String CHALLENGE_CODE_REGEX = "^[0-9]{6}$";

    private RegexUtils() {
    }


}
