import Testing
@testable import KVMCore

struct ProcessOutputTests {
    @Test func argumentsArePassedLiterally() throws {
        let text = try ProcessOutput.capture("/usr/bin/printf", ["%s", "a space; $HOME"], timeout: 5)
        #expect(text == "a space; $HOME")
    }
    @Test func largeOutputDoesNotDeadlock() throws {
        let text = try ProcessOutput.capture("/usr/bin/head", ["-c", "262144", "/dev/zero"], timeout: 5)
        #expect(text.utf8.count == 262144)
    }
    @Test func failedCommandsPreserveExitStatus() {
        do {
            _ = try ProcessOutput.capture("/usr/bin/false", [], timeout: 5)
            Issue.record("Expected a command failure")
        } catch ActuatorError.commandFailed(_, let code, _) { #expect(code == 1) }
        catch { Issue.record("Unexpected error: \(error)") }
    }
}
