package de.thb.guessingaverage.controller;

import de.thb.guessingaverage.controller.form.NumberEntryFormModel;
import de.thb.guessingaverage.repositories.NumberEntryRepository;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class NumberEntryControllerTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private NumberEntryRepository numberEntryRepository;

    @Test
    void test_is_there_a_webpage() {
        ResponseEntity<String> response = restTemplate.getForEntity("/", String.class);
        Assertions.assertEquals(HttpStatus.OK, response.getStatusCode(), "The web page should be available.");
    }

    @Test
    void test_is_there_a_webpage_with_wrong_path() {
        ResponseEntity<String> response = restTemplate.getForEntity("/this_is_a_wrong_path", String.class);
        Assertions.assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode(), "The web page should not be available.");
    }

    @Test
    void test_post_number() {
        NumberEntryFormModel form = new NumberEntryFormModel();
        float number = 1.f;
        form.setNumber(number);
        ResponseEntity<String> response = restTemplate.postForEntity("/", form, String.class);
        Assertions.assertEquals(HttpStatus.OK, response.getStatusCode(), "The web page should be available.");
        numberEntryRepository.delete(numberEntryRepository.findTopByOrderByIdDesc());
    }

    @Test
    void test_post_number_with_wrong_path() {
        NumberEntryFormModel form = new NumberEntryFormModel();
        float number = 2.f;
        form.setNumber(number);
        ResponseEntity<String> response = restTemplate.postForEntity("/this_is_a_wrong_path", form, String.class);
        Assertions.assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode(), "The web page should not be available.");
    }

}
