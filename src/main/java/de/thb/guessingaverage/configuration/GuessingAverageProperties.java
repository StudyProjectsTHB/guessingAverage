package de.thb.guessingaverage.configuration;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "guessing.average")
@Getter
@Setter
public class GuessingAverageProperties {
    private int maxValue;
    private int minValue;
    private int minNumber;
    private int maxNumber;
    private int randomNumbersFrequency;
}
