import std.stdio;
import std.file;
import std.array;
import core.stdc.stdlib;
import std.conv : to;
import bt_fnc;
import rimtypes;
import jsvar;

string rimvm_ver = "1.0";

int argtype_int8 = 0;
int argtype_string = 1;
int argtype_unknown = -1;

int ip = 0;
RimVar[] stack;
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
						stack ~= new RimVar(2, psh);
						writeln("[*] Pushed string " ~ psh);
						break;
					case type_int8:
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
					args ~= stack[stack.length - 1];
					stack.popBack();
				}
				rimfns[id].fn(args);
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