  ** Tnt Delphi UNICODE Controls Project **

  ** For Borland C++ Builder 5 **


These projects build the design-time and run-time packages for use with
Borland C++ Builder 5. To build from scratch, do this:

1.  Build the C++ Builder run-time package TntLibR.bpk. The project file is
    configured to put all output in the same directory that contains the
    project file.

2.  Open and build the C++ Builder design-time package TntLibD.bpk. Like the
    run-time project file, it is configured to place all output in the same
    directory that contains the project file.

3.  Install the C++ Builder-built package that you created in
    step 2 (Menu->Component->Install Packages, then use the top-most Add
    button...)


To build distributable applications using the Tnt package, either:

-   statically link the TntLibR.lib file (this is the default behavior; the
    C++ Builder IDE adds a #pragma link statement to any unit file that
    contains a Tnt control)

-   remove the #pragma link statements, and in the project options on the
    Packages tab, enable "Build with runtime packages" and enter TntLibR in
    the list of packages

