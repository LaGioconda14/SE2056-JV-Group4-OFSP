package service;

import java.util.List;
import model.dto.common.Province;

public interface IAddressLookupService {

    List<Province> getAllProvinces();

    String getProvincesJson();

    String getWardsJson(String provinceCode);
}
