package core.logger;
import core.logger.base.CoreBaseLogger;
import js.Node;
class CoreLoggerNodeJsConsole extends CoreBaseLogger {
    public function new() {
        super();
    }

    @:protected override function addLogEntry(message:Dynamic, ?pos:haxe.PosInfos):Void {
        Node.console.trace("utils console log:"+createEntryFrom(message));
    }
}
