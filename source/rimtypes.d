import jsvar;

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

class RimByte
{
	char bt;
	bool eof;
}