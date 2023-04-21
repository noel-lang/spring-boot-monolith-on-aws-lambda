package de.noellang.springbootawslambda;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.NoHandlerFoundException;

@SpringBootApplication
@RestController
public class SpringBootAwsLambdaApplication {

	public static void main(String[] args) {
		SpringApplication.run(SpringBootAwsLambdaApplication.class, args);
	}

	@ExceptionHandler(NoHandlerFoundException.class)
	public ResponseEntity<ErrorResponse> handleNotFoundError() {
		ErrorResponse errorResponse = new ErrorResponse("Resource not found");
		return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
	}

	@GetMapping("/hello-world")
	public ResponseEntity<String> helloWorld() {
		return ResponseEntity.ok("Hello World 123! Heheeeee");
	}

	@GetMapping("/")
	public String standard() {
		return "Das ist ein anderer Default-Wert 123! 456 trololo";
	}

	private static class ErrorResponse {
		private String message;

		public ErrorResponse(String message) {
			this.message = message;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}
	}

}
