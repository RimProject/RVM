import rimtypes;

char nop = cast(char)0;
char push = cast(char)1;
char call = cast(char)2;
char pushglobal = cast(char)3;
char popglobal = cast(char)4;
char stackop = cast(char)5;

char type_unk = cast(char)0;
char type_int32 = cast(char)1;
char type_str = cast(char)2;


class RimFunc
{
	int argcount;
	RimVar[] function(RimVar[] args) fn;
	this(int a, RimVar[] function(RimVar[] args) f)
	{
		argcount = a;
		fn = f;
	}
}

RimFunc[] rimfns = [
	new RimFunc(1, &rimprint)
];

void init()
{
	/*RimFunc rimp = new RimFunc();
	rimp.argcount = 0;
	rimp.fn = delegate(RimVar[] args){return rimprint(args);};
	rimfns ~= rimp;*/
}
RimVar[] rimprint(RimVar[] args)
{
	import std.stdio;
	writeln(args[0].ArgObj);
	return args;
}