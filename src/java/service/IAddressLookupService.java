package service;

public interface IAddressLookupService {

    String getProvincesJson();

    String getWardsJson(String provinceCode);
}
