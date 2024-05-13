To use the Dockerfile:
- add domain.pddl into same folder
- generate problem files and put them into the "problems" folder
- build 
- entrypoint is the popf planning command: 
    "docker run name" + any argument that popf-clp takes
    to test any problem: "docker run name domain.pddl problem.pddl" 