import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.security.auth.SecurityProtocol;
import org.apache.kafka.common.serialization.StringSerializer;
import org.junit.Ignore;
import org.junit.Test;

import java.util.Properties;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

public class ProduceDataTest {

    // This test will not work until advertised listeners is set correctly in docker-compose.yml .
    @Test
    @Ignore
    public void test() throws ExecutionException, InterruptedException {
        Properties producerConfig = new Properties();
        producerConfig.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9093");
        producerConfig.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        producerConfig.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        producerConfig.put(ProducerConfig.RETRIES_CONFIG, 0);
        producerConfig.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 3000);
        producerConfig.put(ProducerConfig.LINGER_MS_CONFIG, 1000);
        producerConfig.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 1000);
        producerConfig.put("sasl.mechanism", "OAUTHBEARER");
        producerConfig.put("security.protocol", SecurityProtocol.SASL_PLAINTEXT.name);
        producerConfig.put("sasl.jaas.config", "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required unsecuredLoginStringClaim_sub=\"alice\";");
        producerConfig.put("sasl.login.callback.handler.class", "io.confluent.examples.authentication.oauth.OauthBearerLoginCallbackHandler");
        KafkaProducer<String, String> kafkaProducer = new KafkaProducer<>(producerConfig);
        Future<RecordMetadata> result = kafkaProducer.send(new ProducerRecord<>("foo", "bar"));
        result.get();
    }
}
