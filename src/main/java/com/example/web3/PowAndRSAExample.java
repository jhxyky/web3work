package com.example.web3;

/**
 * 2025/4/28作业
 * 实践 POW ⽤⾃⼰的昵称 + nonce， 不断的 sha256 Hash :
 * ❖ 直到满⾜ 4个0开头，打印出花费的时间
 * ❖ 直到满⾜ 5个0开头，打印出花费的时间
 * ❖ 实践⾮对称加密 RSA
 * ❖ 先⽣成⼀个公私钥对
 * ❖ ⽤私钥对符合POW⼀个昵称 + nonce 进⾏私钥签名
 * ❖ ⽤公钥验证
 */
import java.security.*;
import java.util.Base64;
import javax.xml.bind.DatatypeConverter;

public class PowAndRSAExample {

    public static void main(String[] args) throws Exception {
        String nickname = "焦某人"; // 你的昵称
        System.out.println("开始POW实验：");

        // POW 找4个0开头
        String result4 = findHash(nickname, 4);
        System.out.println("4个0的结果：" + result4);

        // POW 找5个0开头
        String result5 = findHash(nickname, 5);
        System.out.println("5个0的结果：" + result5);

        System.out.println("\n开始RSA实验：");

        // 生成RSA公私钥
        KeyPair keyPair = generateRSAKeyPair();
        PrivateKey privateKey = keyPair.getPrivate();
        PublicKey publicKey = keyPair.getPublic();

        // 用私钥对POW的结果进行签名
        String signature = sign(result5, privateKey);
        System.out.println("签名结果：" + signature);

        // 用公钥验证签名
        boolean isValid = verify(result5, signature, publicKey);
        System.out.println("签名验证结果：" + isValid);
    }

    // POW部分：找到指定前缀的hash
    public static String findHash(String base, int zeroCount) throws Exception {
//        String prefix = "0".repeat(zeroCount);
        String prefix = repeat("0", zeroCount);
        int nonce = 0;
        long startTime = System.currentTimeMillis();

        while (true) {
            String input = base + nonce;
            String hash = sha256(input);
            if (hash.startsWith(prefix)) {
                long endTime = System.currentTimeMillis();
                System.out.println(zeroCount + "个0开头找到的nonce：" + nonce);
                System.out.println(zeroCount + "个0开头花费时间：" + (endTime - startTime) + "ms");
                System.out.println("对应hash：" + hash);
                return input; // 返回昵称+nonce
            }
            nonce++;
        }
    }

    public static String repeat(String str, int times) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < times; i++) {
            sb.append(str);
        }
        return sb.toString();
    }

    // 生成SHA-256哈希
    public static String sha256(String input) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(input.getBytes("UTF-8"));
        return DatatypeConverter.printHexBinary(hash).toLowerCase();
    }

    // 生成RSA密钥对
    public static KeyPair generateRSAKeyPair() throws Exception {
        KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
        generator.initialize(2048); // 2048位，安全
        return generator.generateKeyPair();
    }

    // 用私钥签名
    public static String sign(String data, PrivateKey privateKey) throws Exception {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(privateKey);
        signature.update(data.getBytes("UTF-8"));
        byte[] signedBytes = signature.sign();
        return Base64.getEncoder().encodeToString(signedBytes);
    }

    // 用公钥验证
    public static boolean verify(String data, String signatureStr, PublicKey publicKey) throws Exception {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initVerify(publicKey);
        signature.update(data.getBytes("UTF-8"));
        byte[] signatureBytes = Base64.getDecoder().decode(signatureStr);
        return signature.verify(signatureBytes);
    }
}
