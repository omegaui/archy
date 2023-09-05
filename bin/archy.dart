import 'dart:io';

enum GenType {
  feature,
  core,
}

bool yesToAll = false;
bool noToAll = false;

List<String> arguments = [];

void main(List<String> args) {
  arguments = args;

  print("Welcome to archy !!");
  print("Clean Architecture boilerplate Code Generator (Flutter with GetX)");
  print("");

  var option = args[0];

  switch (option) {
    case "create":
      var projectName = args[1];
      initStructure(projectName);
      break;
    case "--gen":
      var genType = args[1];
      switch (genType) {
        case "feature":
          gen();
          break;
        case "core":
          gen(type: GenType.core);
          break;
      }
      break;
  }
}

void gen({GenType type = GenType.feature}) {
  switch (type) {
    case GenType.feature:
      genFeature();
      break;
    case GenType.core:
      genCore();
      break;
  }
}

void genFeature() {
  // arguments[2] is --name.
  var name = arguments[3];
  var featureRoot = ['lib', 'app'].join(Platform.pathSeparator);
  constructPath([featureRoot, name]);

  // data layer
  constructPath(
    [featureRoot, name, 'data', '${name}_repository_impl.dart'],
    type: FileSystemEntityType.file,
  );

  // domain layer
  constructPath([featureRoot, name, 'domain', 'entity']);
  constructPath(
    [featureRoot, name, 'domain', 'repository', '${name}_repository.dart'],
    type: FileSystemEntityType.file,
  );
  constructPath([featureRoot, name, 'domain', 'usecases']);

  // presentation layer
  constructPath([
    featureRoot,
    name,
    'presentation',
  ]);

  // arguments[4] is --states
  var states = arguments.getRange(5, arguments.length);
  for (var state in states) {
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

void genCore() {
  // TODO: This functionality is pending
  logInfo("This functionality is pending");
}

void initStructure(String projectRoot) {
  if (projectRoot == '.') {
    projectRoot = Directory.current.path.substring(
        Directory.current.path.lastIndexOf(Platform.pathSeparator) + 1);
  } else {
    constructPath([projectRoot]);
  }

  logInfo("Generating boilerplate Structure in $projectRoot ...");

  var sourceRoot = "$projectRoot${Platform.pathSeparator}lib";

  constructPath([sourceRoot, 'app']);
  constructPath([sourceRoot, 'core', 'database', 'data']);
  constructPath([sourceRoot, 'core', 'database', 'domain']);
  constructPath([sourceRoot, 'config', 'theme']);
  constructPath([sourceRoot, 'config', 'assets']);
  constructPath([sourceRoot, 'constants']);

  logWarning(
      "\nBefore running gen commands, switch to root dir by running:\n\tcd $projectRoot\n");
}

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

String ask(String text) {
  logSuccess("$text [Y/n]");
  var input = stdin.readLineSync();
  return input ?? "n";
}

String input(String text) {
  logSuccess(text);
  var input = stdin.readLineSync();
  return input ?? "";
}

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
