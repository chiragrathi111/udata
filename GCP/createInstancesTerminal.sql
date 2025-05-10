//gcp instances working in terminal

gcloud compute instances create <inatances name> --machine-type <enter machine type> --zone <enter zone name>
//<inatances name> = chirag
//<enter machine type> = n1-standard-2(2=cpu) (custom choose and ram also provided but ram put only kb type like 1024=1gb)
//<enter zone name> = asia-south1-a 

gcloud compute ssh <inatances name> --zone=asia-south1-a

gcloud compute images list (show images list)
create instances choose another images

gcloud compute instances create <inatances name> --image-family <enter images family name> --image-project <enter image project name> --zone <enter zone name>

gcloud compute instances describe <inatance name>

gcloud compute instances stop <instances name>

sudo gcloud compute instances start <instance name>

sudo gcloud compute instances delete <instance name>
