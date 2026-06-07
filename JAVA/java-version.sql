Change the java version :-

Parmanent change :-

# Step 1: Set Java 17 correctly
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Step 2: Set JAVA_HOME in your shell
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

# Step 3: Reload shell
source ~/.bashrc

# Step 4: Verify
java -version
javac -version

---------------------------------------------------------

Specific terminal java version :-

JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ./mvnw clean package -DskipTests
