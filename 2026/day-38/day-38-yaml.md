# Day 38 – YAML Basics
## Task 1: Key-Value Pairs

+ Create person.yaml that describes yourself with:

    + name
    + role
    + experience_years
    + learning (a boolean)
```YAML
name: Aliya Firdous
role: DevOps Learner
experience_years: 0
learning: true
```

+ Verify: Run cat person.yaml — does it look clean? No tabs?


---

## Task 2: Lists

+ Add to person.yaml:

   + tools — a list of 5 DevOps tools you know or are learning
   + hobbies — a list using the inline format [item1, item2]
```YAML
tools:
  devops:
    - github action
    - jenkins
    - kubernaties
    - github
    - terraform
hobbies: [traveling, Learning, cooking, walking]
  ```

+  Write in your notes: What are the two ways to write a list in YAML?
    + there are two ways to write a list in yml
       1) Each item starts with -
          + example :
 ``` YAML
  tools:
    devops:
    - github action
    - jenkins
    - kubernaties
    - github
    - terraform
```
2) Written in square brackets Comma-separated
    + example:
      ```YAML
      hobbies: [traveling, Learning, cooking, walking]
      ```
---

## ask 3: Nested Objects

+ Create server.yaml that describes a server:

  +  server with nested keys: name, ip, port
    ```YAML
  server:
    name: MyServer
    port: 8080
    ip: 192.168.1.10
   ```
  +  database with nested keys: host, name, credentials (nested further: user, password)
```YAML
 Database:
  host: localhost
  name: mydb
 credentials:
  user: admin
  password: 12345
 ```

Verify: Try adding a tab instead of spaces — what happens when you validate it? 
+ YAML does NOT allow tabs for indentation
+ so when we uses tab instead pf space we get error
---

  ## Task 4: Multi-line Strings

+ In server.yaml, add a startup_script field using:

   + The | block style (preserves newlines)

```YAML
startup_scripts: |
  #!/bin/bash
  echo "Starting MyServer"
  sudo systemctl start nginx
  echo "Server is up and running"
```
### it became
``` 
#!/bin/bash
echo "Starting  Myserver"
echo "Server system starting"
echo "My server is up and  running"
```
  + The > fold style (folds into one line)
```YAML
startup_scripts: >
  #!/bin/bash
  echo "Starting MyServer"
  sudo systemctl start nginx
  echo "Server is up and running"
```
### it became :
```YAML
#!/bin/bash echo "Starting Myserver" server system is starting echo "My server is up and running"
```
Write in your notes: When would you use | vs >?

 + use | :-
 + Writing shell scripts
 + Writing multi-line commands

+ use  > :-
+ Writing long descriptions
+ Writing comments


---
## ask 5: Validate Your YAML

  + Install yamllint or use an online validator
      + ```pip install yamllint```
  +  Validate both your YAML files
      + ```  yamllint person.yaml```
      + ``` yamllint server.yaml```
  +  Intentionally break the indentation — what error do you get? Fix it and validate again

      +  1:1  warning  missing document start "---"  (document-start)
      +  2:3       error    wrong indentation: expected 0 but found 2  (indentation)
      +  6:1       error    syntax error: expected '<document start>', but found '<block mapping start>' (syntax)
---
## Task 6: Spot the Difference

Read both blocks and write what's wrong with the second one:
```YAML
# Block 2 - broken
name: devops
tools:
- docker
  - kubernetes
```
+ bad indentation!!
+ List items under tools are not aligned at the same indentation level

  
