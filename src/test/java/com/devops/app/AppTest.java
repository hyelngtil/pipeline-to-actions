// =============================================================================
// AppTest.java — Unit Tests for App.java
// =============================================================================
// This test class validates the App.java business logic. In the CI pipeline,
// GitHub Actions runs 'mvn test' which automatically discovers and executes
// all test classes in src/test/java.
//
// WHY THIS MATTERS FOR CI/CD:
// The 'build' job in our GitHub Actions workflow runs 'mvn test'. If any
// test fails, the entire pipeline STOPS — the Docker image is never built,
// and nothing is deployed to ECS. This is the "Continuous Integration" part:
// every code change is automatically validated before it can reach production.
// =============================================================================

package com.devops.app;

// JUnit 4 imports — the testing framework
import org.junit.Test;           // Marks a method as a test case
import static org.junit.Assert.*; // Provides assertion methods (assertEquals, etc.)

/**
 * Unit test class for {@link App}.
 * 
 * JUnit naming convention: the test class name is the source class name
 * with "Test" appended (App → AppTest). Maven's Surefire plugin uses
 * this naming pattern to auto-discover tests.
 */
public class AppTest {

    /**
     * Tests that the getGreeting() method returns the expected string.
     * 
     * The @Test annotation tells JUnit this method is a test case.
     * If the assertion fails, JUnit reports the test as FAILED,
     * and the Maven build (and therefore the CI pipeline) will fail.
     */
    @Test
    public void testGetGreeting() {
        // Arrange — create an instance of the class under test
        App app = new App();

        // Act — call the method we want to test
        String result = app.getGreeting();

        // Assert — verify the result matches our expectation
        // If this fails, you'll see: "Expected: Pipeline to Actions is running! 
        //                             Actual: <whatever was returned>"
        assertEquals("Pipeline to Actions is running!", result);
    }
}

