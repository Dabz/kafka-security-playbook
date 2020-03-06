package com.purbon.security.tls;

import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

public class DefaultTrustManager extends AbstractTrustManager {

  public void checkClientTrusted(X509Certificate[] chain, String authType)
      throws CertificateException {

  }

  public void checkServerTrusted(X509Certificate[] chain, String authType)
      throws CertificateException {

  }
}
