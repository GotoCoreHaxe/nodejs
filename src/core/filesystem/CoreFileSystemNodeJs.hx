package core.filesystem;
import core.base.CoreClass;
import core.filesystem.base.IFileSystem;
import js.Error;
import js.node.buffer.Buffer;
import js.node.Fs;
import js.node.Path;
import js.Node;
class CoreFileSystemNodeJs extends CoreClass implements IFileSystem {
    public function new() {
        super();
    }

    public function desktopDirectory():String {
        return getHomeDir() + "/Desktop";
    }

    public function documentDirectory():String {
        return getHomeDir() + "/Documents";
    }

    public function userDirectory():String {
        return getHomeDir();
    }


    public function appDirectory():String {
        if (Node.process.platform == 'win32')
            return Node.process.env["CD"];
        return Node.process.env["PWD"];
    }


    private function getHomeDir():String {
        if (Node.process.platform == 'win32')
            return Node.process.env["HOMEPATH"];
        return Node.process.env["HOME"];
    }

    public function getSubFolders(path:String):Array<String> {
        return Fs.readdirSync(path);
    }

    public function getFiles(path:Dynamic, filter:Array<String>):Array<String> {
        var result:Array<String> = new Array<String>();
        result.push(path);
        return result;
    }

    public function fileExists(path:String):Bool {
        return this.exists(path);
    }

    public function folderExists(path:String):Bool {
        return this.exists(path);
    }

    private function exists(path:String):Bool {
        return Fs.existsSync(path);
    }

    public function createFolder(path:Dynamic):Void {


        if (!Path.isAbsolute(path))
            path = Path.resolve(path);

        var segments:Array<String> = path.split(Path.sep);
        var current = '';
        var i = 0;

        while (i < segments.length) {
            current = current + Path.sep + segments[i];
            try {
                Fs.statSync(current);
            } catch (e:Error) {
                Fs.mkdirSync(current);
            }

            i++;
        }
    }

    public function copyFile(from:Dynamic, to:Dynamic):Void {

        Fs.createReadStream(from).pipe(Fs.createWriteStream(to));
    }

    public function copyFolder(src:Dynamic, dest:Dynamic):Void {
        this.createFolder(dest);
        var files = Fs.readdirSync(src);
        for (i in 0...files.length) {
            var current = Fs.lstatSync(Path.join(src, files[i]));
            if (current.isDirectory()) {
                this.copyFolder(Path.join(src, files[i]), Path.join(dest, files[i]));
            } else if (current.isSymbolicLink()) {
                var symlink = Fs.readlinkSync(Path.join(src, files[i]));
                Fs.symlinkSync(symlink, Path.join(dest, files[i]));
            } else {
                this.copyFile(Path.join(src, files[i]), Path.join(dest, files[i]));
            }
        }

    }

    public function moveFolder(from:Dynamic, to:Dynamic):Void {
        this.createFolder(Path.dirname(to));
        Fs.renameSync(from, to);
    }

    public function moveFile(from:Dynamic, to:Dynamic):Void {
        this.createFolder(Path.dirname(to));
        Fs.renameSync(from, to);
    }

    public function writeTextFile(path:Dynamic, content:Dynamic, appendable:Bool = false):Void {
        this.write(path, content, appendable);
    }

    public function writeBinaryFile(path:Dynamic, content:Dynamic, appendable:Bool = false):Void {
        this.write(path, new Buffer(content, "base64"), appendable);
    }

    private function write(path:Dynamic, content:Dynamic, appendable:Bool):Void {
        this.createFolder(Path.dirname(path));
        Fs.writeFileSync(path, content, {flag:(appendable) ? "a" : "w"});

    }


    public function readTextFile(path:Dynamic):String {
        return Fs.readFileSync(path, {encoding:'utf8'});
    }

    public function readBinaryFile(path:Dynamic):Dynamic {
//        var rstream:ReadStream = Fs.createReadStream(path);
//        return rstream.read();
        return Fs.readFileSync(path);

    }

    public function deleteFolder(path:Dynamic):Void {
        var list = Fs.readdirSync(path);
        for (i in 0...list.length) {
            var filename = Path.join(path, list[i]);
            var stat = Fs.statSync(filename);

            if (filename == "." || filename == "..") {
            } else if (stat.isDirectory()) {

                this.deleteFolder(filename);
            } else {

                Fs.unlinkSync(filename);
            }
        }
        Fs.rmdirSync(path);
    }

    public function deleteFile(path:Dynamic):Void {
        if (this.exists(path))
            Fs.unlinkSync(path);
    }
}

