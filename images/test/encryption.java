import javax.crypto.Cipher;

public class Encryption {
    public byte[] encryptData(byte[] data, SecretKey key) throws Exception {
        Cipher cipher = Cipher.getInstance("DES");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        return cipher.doFinal(data);
    }
}