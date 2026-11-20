package model.dto.common;

import java.io.Serializable;

public class Province implements Serializable {
    private static final long serialVersionUID = 1L;

    private int code;
    private String name;

    public Province() {
    }

    public Province(int code, String name) {
        this.code = code;
        this.name = name;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
