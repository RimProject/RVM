import jsvar;
import std.array;

class RimVar
{
	var ArgObj;
	int Type;
	this(int t, var o)
	{
		ArgObj = o;
		Type = t;
	}
}

static class rimmanager
{
	static RimVar[] stack;
	static void pushstack(RimVar el)
	{
		this.stack ~= el;
	}
	static RimVar popstack()
	{
		RimVar re = this.stack[stack.length - 1];
		stack.popBack();
		return re;
	}
	static RimVar laststack()
	{
		return this.stack[stack.length - 1];
	}
	
	static RimVar[string] globals;
	static void setvar(string key, RimVar el)
	{
		// TODO
		this.globals[key] = el;
	}
	static RimVar getvar(string key)
	{
		// TODO
		return this.globals[key];
	}
	
}

class RimByte
{
	char bt;
	bool eof;
}