    2  gcloud compute images list (show images list)
    7  gcloud compute instances create chi1 --machine-type n1-standard-2 --zone asia-south1-a (create instances using machine type)
   10  gcloud compute instances create chi-12 --image-family ubuntu-minimal-2210-arm64 --image-project ubuntu-os-cloud --zone=us-west4-b (create instances from images)
   11  gcloud compute instances describe chi-12 (instances full details)
   12  gcloud compute instances delete chi-12 (delete instances)
   20  gcloud compute ssh chirag --zone=us-west4-a  (login instances)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
   
   23  gcloud compute disks resize instance-1 --zone us-west4-b --size 30 (Existing instances storage size up)
   25  gcloud compute ssh instance-1 --zone=us-west4-b

---------------------------------------------------------------------------------------------------------------------------------------------------------------

   29  ls -a $HOME (full list show HOME )
   30  pwd (show current directory path)
   31  gsutil mb -b on -l asia-south1 gs://chirat123/ (create cloud storage Bucket)
   { gsutil = using cloud storage any services (gsutil = google storage utilities)
     l = location(choose region,dualRegion,multiRegion)
     gs:// = using create storage name
   }
   32  gsutil ls
   34  gsutil cp letter-c.jpg gs://chirat123/ 
    (pahle cloud shell mai image or any object ko upload karna padta hai phir hi hum uska use Bucket mai add karne ke liye kar sakte hai)
   35  gsutil ls gs://chirat123/ (list of Bucket)
   36  gsutil cp gs://chirat123/depositphotos_41277661-stock-photo-spring-letter-c.jpg /home/chirag/image.jpg (cloud shell to Bucket copy object)
   39  gsutil iam ch allUsers:objectViewer gs://chirat123 (Bucket permission changes show open_publicly)
   43  gsutil iam ch -d allUsers:objectViewer gs://chirat123 (change permission not show publicly)
   44  gsutil rm gs://chirat123/depositphotos_41277661-stock-photo-spring-letter-c.jpg (remove the object)
   45  gsutil ls gs://chirat123/
   46  gsutil rm -r gs://chirat123/ (remove the bucket)
   47  gsutil ls
   49  history | sudo tee gsutil.sql (file copy methods)

---------------------------------------------------------------------------------------------------------------------------------------------------------------

