# archy

Clean Architecture App Structure generator.

# Install

> First You need to compile the program from project root by running
> `dart compile exe bin/archy.dart`
> Then, you can integrate it with your system.

# Usage

```shell
# to create a project or add directory structure to existing one
archy create super-project 
# to create a feature called 'auth' with states 'splash' and 'auth' along with the controllers, presenters, state-machines, etc.
archy --gen feature --name auth --states splash auth  
```

#### This is just a handy program to do simple directory and file generations, nothing big.
