    1  gcloud compute instances describe
    2  gcloud compute images list
    3  gloud compute instances create chirag --image-family ubuntu-minimal-2304-arm64 --image-project ubuntu-os-cloud --zone asia-south1-c
    4  gcloud compute instances create chirag --image-family ubuntu-minimal-2304-arm64 --image-project ubuntu-os-cloud --zone asia-south1-c
    5  gcloud compute instances create chirag --image-family ubuntu-minimal-2304-arm64 --image-project ubuntu-os-cloud 
    6  gcloud compute instances create chi1 --machine-type n1-standard-2 --zone asia-south1-c
    7  gcloud compute instances create chi1 --machine-type n1-standard-2 --zone asia-south1-a
    8  gcloud conpute images list
    9  gcloud compute images list
   10  gcloud compute instances create chi-12 --image-family ubuntu-minimal-2210-arm64 --image-project ubuntu-os-cloud --zone=us-west4-b 
   11  gcloud compute instances describe chi-12
   12  gcloud compute instances delete chi-12
   13  gcloud compute ssh instance-1 --zone us-west4-b
   14  exit
   15  gcloud compute instances create chirag --machine-type e2-micro-1 --zone us-west4-a
   16  gcloud compute instances create chirag --machine-type e2-meadium-2 --zone us-west4-a
   17  gcloud compute instances create chirag --machine-type n1-standard-1 --zone us-west4-a
   18  gcloud compute instances describe
   19  gcloud compute instances describe chirag
   20  gcloud compute ssh chirag --zone=us-west4-a
   21  exit
   22  gcloud compute disks resize instance-1 --zone us-west4-b 30
   23  gcloud compute disks resize instance-1 --zone us-west4-b --size 30
   24  clear
   25  gcloud compute ssh instance-1 --zone=us-west4-b
   26  exit
   27  gcloud mb -b on -l asia-south-c gs://chirat123/
   28  ls
   29  ls -a $HOME 
   30  pwd
   31  gsutil mb -b on -l asia-south1 gs://chirat123/
   32  gsutil ls
   33  ls
   34  gsutil cp depositphotos_41277661-stock-photo-spring-letter-c.jpg gs://chirat123/
   35  gsutil ls gs://chirat123/
   36  gsutil cp gs://chirat123/depositphotos_41277661-stock-photo-spring-letter-c.jpg /home/chirag/image.jpg
   37  ls
   38  gsutil iam ch allUsers:ObjectViewer gs://chirat123
   39  gsutil iam ch allUsers:objectViewer gs://chirat123
   40  gsutil iam d allUsers:objectViewer gs://chirat123
   41  gsutil iam -d allUsers:objectViewer gs://chirat123
   42  gsutil iam - d allUsers:objectViewer gs://chirat123
   43  gsutil iam ch -d allUsers:objectViewer gs://chirat123
   44  gsutil rm gs://chirat123/depositphotos_41277661-stock-photo-spring-letter-c.jpg 
   45  gsutil ls gs://chirat123/
   46  gsutil rm -r gs://chirat123/
   47  gsutil ls
   49  history | sudo tee gsutil.sql
