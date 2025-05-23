# Example files

https://www.ucamco.com/en/gerber/downloads
https://github.com/hsiang-lee/gerber-parser/tree/master/tests/test_data/gerber/gerber_files
https://github.com/sousarbarb/V7DParser/tree/main/gbr


# Specification

https://www.ucamco.com/files/downloads/file_en/456/gerber-layer-format-specification-revision-2024-05_en.pdf?94b45d8745c1a068fd091f095a26ddeb

# Links

https://www.artwork.com/gerber/appl2.htm

# Development

First, build the software using the make tool by typing make in this folder.

```
make
```

Once the executable is ready, feed it an example file.

```
.\gerber.exe resources\test\GoodFET\07a16ddef66d616a58a6e7265e810823.GTP
```

There should be no syntax error.


# Tools

## gerbv
A tool that really works very, very well is gerbv (https://gerbv.github.io/)
It can read and display individual .gbr files.
It can load several .gbr files at the same time.


# Execution Model

The current point is the X,Y coordinate pair that is treated as the current state of the machine.
A draw operation starts from the current point. The current point is updated to the point where a draw operation ended.
The initial value for the current point is ???



# Open Questions

- Why are some commands wrapped in %...%? What is the benefit, what problem does this solve.
- Form some reason, the D01, D02 and D03 commands are postfixed! They are not placed at the beginning of a line. Why?



# Overall File Format/Structure

The Gerber file format is ASCII text.
Lines are either wrapped in %...% or they are not.

```
%FSLAX46Y46*%
```

A line (optionally wrapped in %...%) starts with a command code and ends with an asterisk.

```
X149000000Y-43750000D02*
```

Content starting with ”#@!“ is reserved for standard comments. The purpose of standard
comments is to add meta-information in a formally defined manner, without affecting image
generation. They can only be used if defined in this specification.

```
G04 #@! TF.FileFunction,Profile,NP*
```



# Format Specification Command - 4.2.2 Format Specification (FS)

The FA command is used once at the beginning of the file to specify how X and Y coordinates are interpreted in the rest of the file.
This means the user has the possibility to define their own coordinate format.
Once specified, all coordinate values in the entire file from start to finish are interpreted in that format.

If the user decides to use a 3.6 format (3 integer and 6 fractional digits), they will insert a FS command like this:

```
%FSLAX36Y36*%
```

It is possible to specifie different formats for the X and the Y coordinate because the command specifies to parameters (X and Y).

The 3.6 format is not the only option. Other formats are possible:

```
%FSLAX24Y24*%
%FSLAX25Y25*%
```

You just have to define a single format at the beginning and then it is used for the rest of the file to interpret coordinates.


The format of the FS command is:

```
'%' ('FS' 'LA' 'X' coord_digits_format 'Y' coord_digits_format) '*%';
```

Example:

%FSLAX36Y36*% Format specification:
 Leading zeros omitted
 Absolute coordinates
 Coordinates in 3 integer and 6 fractional digits

"The resolution of the file 10-6mm, or 1 nm"
I think this sentence is supposed to mean that the resolution is 10^-6 mm which is the same as 1 nm.
1nm = 10^-9 m = 10^-6 * 10^-3 m = 10^-6 mm

Now lets apply the format to a coordinate that might be found in the file somewhere:

X123123456 means X at 123123456 nm == 123123.456um == 123.123456mm

meter = 10^0
millimeter = 10^-3
micrometer = 10^-6
nanometer = 10^-9

"
To interpret a coordinate, it is first left padded with zeros till it has 3+6 digits.
The decimal point is then positioned before the 6th digit starting from the right. There are then 6
decimal digits.
"

The format of numbers is first extended to match the 3.6 format then it is interpreted in mm units:

e.g.
%MOIN*%		- set unit to inch
%MOMM*%		- set unit to mm
X123123456 	- X coordinate - in 3.6 format is 123.123456. Then the unit mm/inch is added which yields: 123.123456 mm/inch
Y23456     	- Y coordinate - in 3.6 format is 000.023456. Then the unit mm/inch is added which yields: 000.023456 mm/inch

%FSLAX25Y25*%

%
FS
LA
X25		- X coordinate - in 3.6 format is 000.000025. Then the unit mm/inch is added which yields: 000.000025 mm/inch
Y25		- Y coordinate - in 3.6 format is 000.000025. Then the unit mm/inch is added which yields: 000.000025 mm/inch
*
%

Coordinate data is in fixed format decimals, expressed in the unit set by the MO command.
Leading zeros may be omitted.
Therefore the MO command has to be used before the FS command.

```
%MOMM*%
%FSLAX36Y36*%
```





# 4.2.1 Unit (MO)

The MO (Mode) command sets the file unit to either metric (mm) or imperial (inch).
The MO command must be used once and only once, in the header of the file, before the first operation command.

The syntax is:

```
MO = '%' ('MO' ('MM'|'IN')) '*%';
```

example:

```
%MOMM*%
```







# Plot Modes

Plot modes affect the D01 command.

- linear plot mode - draws a line segment.
- circular plot mode - draws a circle segment.





# Apertures

An aperture is a 2D plane figure.

The AD (Aperture Define) command creates an aperture based on an aperture template and
parameter values giving it a unique D code or aperture number for later reference.

```
%ADD123R,2.5X1.5%      	<------ This example is taken from page 12 of the spec, but I think this line is invalid because it does not end with an asterisk wrapped in %...%
						<------ I think this line should be %ADD123R,2.5X1.5*%
						<------ This line will cause an error when loading it with gerbv
%ADD123R,2.5X1.5*%
```

The above command is decoded as follows:

%
AD - Aperture Define
D123 - unique D code or aperture number for later reference
R - Aperture Template. Here, the standard template R for rectangle is used.
,
2.5 - parameter 1
X
1.5 - parameter 2
%

There are two kinds of aperture templates

- standard apertures
- aperture templates

## Standard apertures.

They are pre-defined: the circle (C), rectangle (R), obround (O) and regular polygon (P). See 4.4.



# Attributes (Chapter 5)

Gerber files containing attribute commands (TF, TA, TO, TD) are called Gerber X2 files, files without attributes Gerber X1 files.

Attributes add meta-information.
Attributes do not affect the image itself, they only add meta-information to the data.
Attributes can be attached to objects, apertures or to the complete file.

This command defines an attribute indicating the file represents the top solder mask.

```
%TF.FileFunction,Soldermask,Top*%
```



# 8.1.4.3 IP (Image Polarity) Command

'%' ('IP' ('POS'|'NEG')) '*%';

I do not know what effect these commands have yet

%IPPOS*% Image has positive polarity
%IPNEG*% Image has negative polarity


# ???

%FSLAX46Y46*%

# ???

## G01* - 4.7.1 Linear Plotting (G01)

G01 sets linear plot mode. In linear plot mode a D01 operation generates a linear segment, from the current point to the (X, Y) coordinates in the command.
The current point is then set to the (X, Y) coordinates.

The syntax is

('G01') '*';


## G04 - 4.1 Comment (G04) - The G04 command is used for human readable comments. It does not affect the image.

The format is: ('G04' string) '*';

## 4.7.2 Circular Plotting - G02, G03 and G75 circular plotting

```
G02 = ('G02') '*';
G03 = ('G03') '*';
G75 = ('G75') '*';
```

G02 Sets plot mode graphics state parameter to ‘clockwise circular plotting’
G03 Sets plot mode graphics state parameter to ‘counterclockwise circular plotting’
G75 This command must be issued before the first circular plotting operation, for compatibility with older Gerber versions

# 2.6 Operations (D01, D02, D03)

D01, D02 and D03 are the operations. An operation is a command consisting of coordinate data
followed by an operation code. Operations create the graphical objects and/or change the
current point by operating on the coordinate data.

## D01 - 2.3.1 Draws and Arcs - A draw object is created by a command with D01 code in linear plot mode. An arc object is created by a command with D01 code in circular plot mode.

For some reason, the D01, D02 and D03 commands are postfixed! They are not placed at the beginning of a line.

```
X100Y100D01*
X200Y200D02*
X300Y-400D03*
```

D01 creates a linear or circular line segment by plotting from the current point to the coordinate pair in the command.
Outside a region statement (see 2.3.2) these segments are converted to draw or arc objects by stroking them with the current aperture (see 2.3.1).
Within a region statement these segments form a contour defining a region (see 4.10).
The effect of D01, e.g. whether a straight or circular segment is created, depends on the graphics state (see 2.3.2).

D03 creates a flash object by flashing (replicating) the current aperture. The origin of the current aperture is positioned at the specified coordinate pair.


D02 moves the current point (see 2.3.2) to the coordinate pair. No graphical object is created.

D10*
D11*



G54 Select aperture This historic code optionally precedes an aperture selection Dnn command. It has no effect. Sometimes used. Deprecated in 2012.
G55 Prepare for flash This historic code optionally precedes D03 code. It has no effect. Very rarely used nowadays. Deprecated in 2012.
G70 Set the ‘Unit’ to inch These historic codes perform a function handled by the MO command. See 4.2.1. Sometimes used. Deprecated in 2012 G71 Set the ‘Unit’ to mm
G90 Set the ‘Coordinate format’ to ‘Absolute notation’ These historic codes perform a function handled by the FS command. See 4.1. Very rarely used nowadays. Deprecated in 2012. G91 Set the ‘Coordinate format’ to ‘Incremental notation’
G74 Sets single quadrant mode A more complicated way to create arcs. See 8.1.10. Rarely used, and then often without effect. Deprecated in 2020.
M00 Program stop This historic code has the same effect as M02. See 4.13. Very rarely, if ever, used nowadays. Deprecated in 2012.
M01 Optional stop This historic code has no effect. Very rarely, if ever, used nowadays. Deprecated in 2012.
IP Sets the ‘Image polarity’ graphics state parameter This command has no effect in CAD to CAM workflows. Sometimes used, and then usually as %IPPOS*% to confirm the default and it then has no effect. As it is not clear how %IPNEG*% must be handled it is probably a waste of time to try to fully implement it, and sufficient to give a warning on a %IPNEG*% and skip it. Deprecated in 2013
AS Sets the ‘Axes correspondence’ graphics state parameter

IR Sets ‘Image rotation’ graphics state
parameter
Deprecated in 2013. Rarely, if ever, used
nowadays. If used it was nearly always, if not
always, to confirm the default value and then
these commands have no effect.
It is a waste of time to fully implement these
commands. The simplest is simply to ignore these
commands. Theoretically safer is to skip them if
they confirm the default and throw an error on any
other use; chances are you will never see the
error.

MI Sets ‘Image mirroring’ graphics state
parameter

OF Sets ‘Image offset’ graphics state parameter

SF Sets ‘Scale factor’ graphics state parameter

IN Sets the name of the file image. This has
no effect on the image. It is no more than a
comment.
This is just a comment. Use G04 for comments.
See 4.1. Ignore it.
Sometimes used. Deprecated in 2013.

LN Loads a name. Has no effect. It is a
comment.
This is just a comment. Use G04 for comments.
See 4.1. Ignore it.
Sometimes used. Deprecated in 2013.





M02*


# Examples


## Example 1

Below is a small example Gerber file that creates a circle of 1.5 mm diameter centered on the origin.
There is one command per line

```
%FSLAX26Y26*%
%MOMM*%
%ADD100C,1.5*%
D100*
X0Y0D03*
M02*
```

%FSLAX26Y26*%



## Example 2

```
%MOIN*%							// unit is inches
%FSLAX24Y24*%					// format is set to 2 integers and 4 decimals. This is the 2.4 format.
%IPPOS*%						// positive polarity
%ADD11R,0.0393X0.0393*%
G54D11*							// Deprecated command! Select an aperture
X000197Y000197D03*				// D03 command. Set current point to X,Y, then automatically draw the selected aperture. D03 creates a flash object by flashing (replicating) the current aperture. The origin of the current aperture is positioned at the specified coordinate pair.
X049803Y000197D03*
X049803Y049803D03*
X000197Y049803D03*
M02*
```

Here is how the coordinates are interpreted using the 2.4 format specified using FS

1 mil = 1 thousands of an inch = 0.001 inch

X000197Y000197D03* - X == 00.0197 inch =   19.7 mil, Y == 00.0197 inch =   19.7 mil
X049803Y000197D03* - X == 04.9803 inch = 4980.3 mil, Y == 00.0197 inch =   19.7 mil
X049803Y049803D03* - X == 04.9803 inch = 4980.3 mil, Y == 04.9803 inch = 4980.3 mil
X000197Y049803D03* - X == 00.0197 inch = 4980.3 mil, Y == 04.9803 inch = 4980.3 mil