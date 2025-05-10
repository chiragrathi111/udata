Canna Bussiness method:-

1. Create new File in realmeds-selfcare :-
   cd realmeds-selfcare/apiserver/server/configs
    create new file configs folder mai
   #gcp_labels.json (file name) (Ex. - 930270551_labels.json)
    understanding ke liye defaul_labels.json se method ko copy karte hai.
    jo changes karna hai uske only value mai change karna hai

   Ex. - ("medicines": "Product")
    isi prakar jo change karna hai wo karte hai
    Exception :- Batch,Deshboard,Location name change nahi hota hai
 
2. Go to Pgadmin database and create a row :-
   open pgadmin
   realmeds/Schemas/tables/setting
   setting mai right click karke all row ko select karte hai
   + add row ko click karte hai
   name - 930270551_labels
   value - configs/930270551_labels.json
   description mai jo put karna hai wo dal do
   save
   
   
3. Start a server on realmeds-selfcare/apiserver/ :-
    realmeds-selfcare/apiserver/
    node . (server running start) 
    realmeds-selfcare:4200 mai login karke check karo ui mai kuch changes huwa hai ki nahi
    
