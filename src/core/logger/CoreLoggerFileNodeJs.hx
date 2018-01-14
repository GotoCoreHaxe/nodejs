package core.logger;
import core.logger.base.ILogger;
import core.utils.CoreUtils;
import haxe.PosInfos;
import js.node.fs.WriteStream;
import js.node.Fs;
class CoreLoggerFileNodeJs implements ILogger {
    private var stream:WriteStream;

    public function new(path:String) {
        this.stream = Fs.createWriteStream(path, {flags:'a'});
    }

    public function addLog(message:Dynamic, pos:PosInfos):Void {
        this.addLogEntry(message, pos);
    }

    public function addLogEntry(message:Dynamic, ?pos:haxe.PosInfos):Void {
        this.stream.write(createEntryFrom(pos.className + "." + pos.methodName + "(" + pos.lineNumber + "):" + message) + "\n", 'utf8');
    }

    public function createEntryFrom(message:Dynamic):String {
        return (CoreUtils.timeStamp + " ----> " + message);
    }
}
