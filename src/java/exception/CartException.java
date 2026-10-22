package exception;

import java.util.Objects;

public class CartException extends RuntimeException {

    private final CartErrorCode code;

    public CartException(CartErrorCode code, String message) {
        super(message);
        this.code = Objects.requireNonNull(code, "code");
    }

    public CartException(CartErrorCode code, String message, Throwable cause) {
        super(message, cause);
        this.code = Objects.requireNonNull(code, "code");
    }

    public CartErrorCode getCode() {
        return code;
    }
}
