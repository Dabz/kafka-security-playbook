package com.purbon.security.tls;

import java.lang.instrument.Instrumentation;
import javax.net.ssl.HttpsURLConnection;

public class VerificationAgent {

  public static void premain(String args, Instrumentation inst) {
    System.out.println("Initialize the VerificationAgent");
    HttpsURLConnection.setDefaultHostnameVerifier((s, sslSession) -> true);
  }

}
