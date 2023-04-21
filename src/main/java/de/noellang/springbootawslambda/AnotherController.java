package de.noellang.springbootawslambda;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AnotherController {

	@GetMapping("/another-controller")
	public String anotherController() {
		return "Hello!";
	}

}
