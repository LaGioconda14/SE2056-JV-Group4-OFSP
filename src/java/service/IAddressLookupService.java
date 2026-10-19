package service;

public interface IAddressLookupService {

    String getProvincesJson();

    String getDistrictsJson(String provinceCode);

    String getWardsJson(String districtCode);
}
