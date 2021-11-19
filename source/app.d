import std.stdio;
import std.file;
import std.array;
import core.stdc.stdlib;
import std.conv : to;
import bt_fnc;
import rimtypes;
import jsvar;
import std.bitmanip;
import std.system;

string rimvm_ver = "1.0";

int argtype_int8 = 0;
int argtype_string = 1;
int argtype_unknown = -1;

int ip = 0;
RimByte rb;
string bytecode;



void main()
{
    writeln("RimVM v" ~ rimvm_ver);         // Log version
    write("Enter .rbc file path: ");        // Ask for file
    string fn = readln();                   // Read the line and remove
    fn.popBack();                           // Remove last symbol (newline)

    if (!fn.exists)                         // Exit if not exists
    {
        writeln("File not exists!");
        exit(1);
    }
    
	runBytecode(fn);

    write("Press enter to exit. ");         // Exit.
    readln();
}

void runBytecode(string path)
{
	try
	{
		bytecode = readText(path);
	}
	catch (FileException e)
	{
		writeln("Failed to read file: ", e.msg);
		exit(1);
	}
	
	string signature = "RIM" ~ cast(char)0 ~ cast(char)0;
	string readSign = "";
	
	for (int i = 0; i < 5; i++)
	{
		nextbyte_noeof();
		readSign ~= rb.bt;
	}
	
	if (readSign != signature)
	{
		vmpanic("Signatures does not matches! Expected RIM(0)(0), got " ~ readSign, 2);
	}
	init();
	writeln("[*] Loaded successfully");
	
	while (!rb.eof)
	{
		nextbyte();
		switch (rb.bt)
		{
			case nop:
				writeln("[*] NOP");
				break;
			case push:
				writeln("[*] PUSH");
				nextbyte_noeof();
				switch(rb.bt)
				{
					case type_str:
						var psh = "";
						while(rb.bt != cast(char)0)
						{
							nextbyte_noeof();
							psh ~= rb.bt;
						}
						rimmanager.pushstack(new RimVar(2, psh));
						writeln("[*] Pushed string " ~ psh);
						break;
					case type_int32:
						ubyte[] b; // = [0x24, 0x10, 0x00, 0x00];
						var intpsh;
						for (int i = 0; i < 4; i++)
						{
							nextbyte_noeof();
							b ~= cast(ubyte)rb.bt;
						}
						intpsh = peek!(int, Endian.littleEndian)(b);
						rimmanager.pushstack(new RimVar(1, intpsh));
						writeln("[*] Pushed int32 " ~ to!string(intpsh));
						break;
					default:
						vmpanic("Unknown variable type", 5);
						break;
				}
				break;
			case call:
				writeln("[*] CALL");
				char[2] buf;
				for(int i = 0; i < 2; i++)
				{
					nextbyte_noeof();
					buf[i] = rb.bt;
				}
				nextbyte();
				int id = buf[0] | buf[1] << 8;
				writeln("[*] Call func id " ~ to!string(id));
				RimFunc target = rimfns[id];
				RimVar[] args;
				for (int i = 0; i < target.argcount; i++)
				{
					args ~= rimmanager.popstack;
				}
				rimfns[id].fn(args);
				break;
			case pushglobal:
				var psh = "";
				while(rb.bt != cast(char)0)
				{
					nextbyte_noeof();
					psh ~= rb.bt;
				}
				rimmanager.pushstack(rimmanager.getvar(to!string(psh)));
				writeln("[*] Pushed global " ~ to!string(psh) ~ " to stack, value " ~ to!string(rimmanager.getvar(to!string(psh)).ArgObj));
				break;
			case popglobal:
				var psh = "";
				while(rb.bt != cast(char)0)
				{
					nextbyte_noeof();
					psh ~= rb.bt;
				}
				rimmanager.setvar(to!string(psh), rimmanager.popstack);
				writeln("[*] Popped global " ~ to!string(psh) ~ " from stack, value " ~ to!string(rimmanager.getvar(to!string(psh)).ArgObj));
				break;
			default:
				writeln("[!] Unknown");
				break;
		}
	}
}

void vmpanic(string desc, int id)
{
	writeln("Fatal VM error: " ~ desc ~ " (error code " ~ to!string(id) ~ ").\nApplication closed. Press enter to exit.");
	readln();
	exit(id);
}

void nextbyte_noeof()
{
	nextbyte();
	if (rb.eof)
	{
		vmpanic("Unexpected EOF", 3);
	}
}

void nextbyte()
{
	RimByte z = new RimByte();
	z.eof = true;
	if (ip < bytecode.length)
	{
		z.bt = bytecode[ip];
		z.eof = false;
		ip++;
	}
	rb = z;
}