import 'dart:io';

// Define an enumeration for code generation types.
enum GenType {
  feature,
  core,
}

// Flags to handle user input.
bool yesToAll = false;
bool noToAll = false;

// Store command line arguments.
List<String> arguments = [];

// Entry point of the program.
void main(List<String> args) {
  // Store command line arguments.
  arguments = args;

  // Print a welcome message.
  print("Welcome to archy !!");
  print("Clean Architecture boilerplate Code Generator (Flutter with GetX)");
  print("");

  // Determine the chosen option.
  var option = args[0];

  // Perform actions based on the chosen option.
  switch (option) {
    case "create":
      var projectName = args[1];
      initStructure(projectName); // Initialize project structure.
      break;
    case "--gen":
      var genType = args[1];
      switch (genType) {
        case "feature":
          gen(); // Generate feature code.
          break;
        case "core":
          gen(type: GenType.core); // Generate core code.
          break;
      }
      break;
  }
}

// Function to handle code generation based on the specified type.
void gen({GenType type = GenType.feature}) {
  switch (type) {
    case GenType.feature:
      genFeature(); // Generate feature code.
      break;
    case GenType.core:
      genCore(); // Generate core code (pending functionality).
      break;
  }
}

// Function to generate feature-specific code.
void genFeature() {
  // Extract feature name from command line arguments.
  var name = arguments[3];
  var featureRoot = ['lib', 'app'].join(Platform.pathSeparator);
  constructPath([featureRoot, name]);

  // Generate data layer code.
  constructPath(
    [featureRoot, name, 'data', '${name}_repository_impl.dart'],
    type: FileSystemEntityType.file,
  );

  // Generate domain layer code.
  constructPath([featureRoot, name, 'domain', 'entity']);
  constructPath(
    [featureRoot, name, 'domain', 'repository', '${name}_repository.dart'],
    type: FileSystemEntityType.file,
  );
  constructPath([featureRoot, name, 'domain', 'usecases']);

  // Generate presentation layer code.
  constructPath([
    featureRoot,
    name,
    'presentation',
  ]);

  // Extract state names from command line arguments.
  var states = arguments.getRange(5, arguments.length);
  for (var state in states) {
    // Generate state-specific presentation layer code.
    constructPath([featureRoot, name, 'presentation', state, 'states']);
    constructPath(
        [featureRoot, name, 'presentation', state, '${state}_controller.dart'],
        type: FileSystemEntityType.file);
    constructPath(
        [featureRoot, name, 'presentation', state, '${state}_presenter.dart'],
        type: FileSystemEntityType.file);
    constructPath(
        [featureRoot, name, 'presentation', state, '${state}_view.dart'],
        type: FileSystemEntityType.file);
    constructPath([
      featureRoot,
      name,
      'presentation',
      state,
      '${state}_state_machine.dart'
    ], type: FileSystemEntityType.file);
  }
}

// Function to generate core code (pending functionality).
void genCore() {
  logInfo("This functionality is pending");
}

// Function to initialize the project structure.
void initStructure(String projectRoot) {
  if (projectRoot == '.') {
    // If project root is not provided, use the current directory.
    projectRoot = Directory.current.path.substring(
        Directory.current.path.lastIndexOf(Platform.pathSeparator) + 1);
  } else {
    constructPath([projectRoot]);
  }

  logInfo("Generating boilerplate Structure in $projectRoot ...");

  // Define the root directory of the project.
  var sourceRoot = "$projectRoot${Platform.pathSeparator}lib";

  // Generate the directory structure for the project.
  constructPath([sourceRoot, 'app']);
  constructPath([sourceRoot, 'core', 'database', 'data']);
  constructPath([sourceRoot, 'core', 'database', 'domain']);
  constructPath([sourceRoot, 'config', 'theme']);
  constructPath([sourceRoot, 'config', 'assets']);
  constructPath([sourceRoot, 'constants']);

  logWarning(
      "\nBefore running gen commands, switch to root dir by running:\n\tcd $projectRoot\n");
}

// Function to create directories and files as needed.
void constructPath(List<String> path,
    {FileSystemEntityType type = FileSystemEntityType.directory}) {
  String px = path.join(Platform.pathSeparator);
  var pathType = type == FileSystemEntityType.directory ? "path" : "file";
  logInfo("Generating $pathType $px ...");
  switch (type) {
    case FileSystemEntityType.directory:
      Directory(px).create(recursive: true);
      break;
    case FileSystemEntityType.file:
      var file = File(px);
      if (file.existsSync() && !yesToAll && !noToAll) {
        var choice = ask(
            "This path already exists, Do you want to overwrite file? [y/n], A [Yes to All], X [No to All]");
        switch (choice) {
          case 'A':
            yesToAll = true;
          case 'y':
          case 'Y':
            file.create(recursive: true);
            break;
          case 'X':
            noToAll = true;
          case 'n':
          case 'N':
            logWarning("\tSkipping this $pathType!");
            break;
          default:
            logError("\tInvalid Choice: $choice\n\tSkipping this path!");
        }
      } else if (!noToAll) {
        file.create(recursive: true);
      } else {
        logWarning("\tSkipping this $pathType!");
      }
      break;
    default:
  }
}

// Function to ask for user input and return the response.
String ask(String text) {
  logSuccess("$text [Y/n]");
  var input = stdin.readLineSync();
  return input ?? "n";
}

// Function to prompt for user input and return the response.
String input(String text) {
  logSuccess(text);
  var input = stdin.readLineSync();
  return input ?? "";
}

// Functions to log different types of messages.
void logInfo(String msg) {
  print('[INFO] \x1B[1;34m$msg\x1B[0m');
}

void logSuccess(String msg) {
  print('\x1B[1;32m$msg\x1B[0m');
}

void logWarning(String msg) {
  print('[WARNING] \x1B[1;33m$msg\x1B[0m');
}

void logError(String msg) {
  print('[ERROR] \x1B[1;31m$msg\x1B[0m');
}
