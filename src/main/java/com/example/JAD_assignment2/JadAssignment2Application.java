package com.example.JAD_assignment2;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories("repository")
@EntityScan("model")
@ComponentScan({"controller","service","repository","model"})
public class JadAssignment2Application {

	public static void main(String[] args) {
		SpringApplication.run(JadAssignment2Application.class, args);
	}

}
