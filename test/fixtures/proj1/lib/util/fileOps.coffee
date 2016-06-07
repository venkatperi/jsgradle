###
   File file(Object path);
    File file(Object path, PathValidation validation);
    URI uri(Object path);
    FileResolver getFileResolver();
    String relativePath(Object path);
    ConfigurableFileCollection files(Object... paths);
    ConfigurableFileTree fileTree(Object baseDir);
    ConfigurableFileTree fileTree(Map<String, ?> args);
    FileTree zipTree(Object zipPath);
    FileTree tarTree(Object tarPath);
    CopySpec copySpec();
    WorkResult copy(Action<? super CopySpec> action);
    WorkResult sync(Action<? super CopySpec> action);
    File mkdir(Object path);
    boolean delete(Object... paths);
    WorkResult delete(Action<? super DeleteSpec> action);
    ResourceHandler getResources();
###

Q = require 'q'
mkdirp = require 'mkdirp'

mkdir = Q.denodeify mkdirp

module.exports = {
  mkdir
}
