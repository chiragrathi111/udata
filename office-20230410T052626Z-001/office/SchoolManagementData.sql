'use strict';
//escapeJson method are using array varible to convert in string valus use JSON.stringify ke surrounded escapeJson ka use hota hai.
const escapeJson = require('escape-json-node/lib/escape-json'); //This line also very usefull because this line not use you are not use escapeJson method ;
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Schoolmanagement) {

    let defineHeadmasterFormat = function(){
        let headMasterModel = {
            'id' : String,
            'name' : String,
            'doj' : String,
            'degree' : String
        };
        ds.define('headmaster',headMasterModel);
    };
    defineHeadmasterFormat();  

    let defineTeacherFormat = function(){
        let headTeacherModel = {
            'teacherId' : String,
            'name' : String,
            'doj' : String,
            'degree' : String,
            'subject' : String,
            'classlist' : String  //Array to String convert because you are not convert your data is not visible
        };
        ds.define('teacher',headTeacherModel);
    };
    defineTeacherFormat();

    let defineClassFormat = function(){
        let headClassModel = {
            'classId' : String,
            'studentList' : String,  //Array to String convert because you are not convert your data is not visible
            'subjectList' : String  //Array to String convert because you are not convert your data is not visible
        };
        ds.define('class',headClassModel);
    };
    defineClassFormat();

    let defineStaffFormat = function(){
        let headStaffModel = {
            'staffId' : String,
            'name' : String,
            'doj' : String,
            'degree' : String,
            'department' : String
        };
        ds.define('staff',headStaffModel);
    };
    defineStaffFormat();

    let defineSchoolFormat = function(){
        let headSchoolModel = {
            'schoolId' : String,
            'name' : String,
            'city' : String,
            'headmaster' : String,
            'teachers' : String, //Array to String convert because you are not convert your data is not visible
            'address' : String
        };
        ds.define('school',headSchoolModel);
    };
    defineSchoolFormat();

    let defineStudentFormat = function(){
        let headStudentModel = {
            'studentId' : String,
            'name' : String,
            'DOB' : String,
            'classs' : String,
            'sex' : String,
            'address' : String
        };
        ds.define('student',headStudentModel);
    };
    defineStudentFormat();

    Schoolmanagement.addHeadMasterData = async function (datah){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
          'addHeadmaster',
          datah.id,
          datah.name,
          datah.doj,
          datah.degree  
        );
        return result;
    }

    Schoolmanagement.addTeacherData = async function(datat){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addTeacher',
            datat.teacherId,
            datat.name,
            datat.doj,
            datat.degree,
            datat.subject,
            escapeJson(JSON.stringify(datat.classlist))
        );
        return result;
    }

    Schoolmanagement.addClassData = async function(datac){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addClass',
            datac.classId,
            escapeJson(JSON.stringify(datac.studentList)),
            escapeJson(JSON.stringify(datac.subjectList))
        );
        return result;
    }

    Schoolmanagement.addStaffData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addStaff',
            data.staffId,
            data.name,
            data.doj,
            data.degree,
            data.department
            );
            return result;
    }

    Schoolmanagement.addSchoolData  = async function(datas){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addSchoolData',
            datas.schoolId,
            datas.name,
            datas.city,
            datas.headmaster,
            escapeJson(JSON.stringify(datas.teachers)),
            datas.address
        );
        return result
    }

    Schoolmanagement.addStudentData = async function(datast){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addStudent',
            datast.studentId,
            datast.name,
            datast.DOB,
            datast.classs,
            datast.sex,
            datast.address
        );
        return result
    }

    Schoolmanagement.getStudentData = async function(studentId){
        const contract = await chaincode.validateUser('user3')

        var studentResult = await contract.evaluateTransaction('queryState',studentId);
        studentResult = JSON.parse(studentResult.toString());
        return studentResult;
    }

    Schoolmanagement.getTeacherData = async function(teacherId){
        const contract = await chaincode.validateUser('user3')

        var teacherResult = await contract.evaluateTransaction('queryState',teacherId);
        teacherResult = JSON.parse(teacherResult.toString());
        return teacherResult;
    }

    Schoolmanagement.getHeadmasterData = async function(headmasterId){
        const contract = await chaincode.validateUser('user3')

        var headmasterResult = await contract.evaluateTransaction('queryState',headmasterId);
        headmasterResult = JSON.parse(headmasterResult.toString());
        return headmasterResult;
    }

    Schoolmanagement.getStaffData = async function(staffId){
        const contract = await chaincode.validateUser('user3')

        var staffResult = await contract.evaluateTransaction('queryState',staffId);
        staffResult = JSON.parse(staffResult.toString());
        return staffResult;
    }

    Schoolmanagement.getSchoolData = async function(schoolId){
        const contract = await chaincode.validateUser('user3')

        var schoolResult = await contract.evaluateTransaction('queryState',schoolId);
        schoolResult = JSON.parse(schoolResult.toString());
        return schoolResult;
    }

    Schoolmanagement.getClassData = async function(classId){
        const contract = await chaincode.validateUser('user3')

        var classResult = await contract.evaluateTransaction('queryState',classId);
        classResult = JSON.parse(classResult.toString());
        return classResult;
    }
//Pagination
        Schoolmanagement.getStudentDataWithPagination = async function(data){
        const contract = await chaincode.validateUser('user3')
        let filterObject = {
            "docType": "student"
        }
        filterObject = escapeJson(JSON.stringify(filterObject));

        if(data.bookmark === undefined){
            data.bookmark = "";
        }
        if(data.pageSize === undefined){
            data.pageSize = 5;
        }
        var result = await contract.evaluateTransaction(
            'filterDataWithPagination',
            filterObject,
            data.pageSize.toString(),
            data.bookmark
        );
        return JSON.parse(result.toString());
    }

    Schoolmanagement.remoteMethod('getStudentDataWithPagination',{
        accepts: [
            {arg: 'data',type: 'object', http: {source: 'body'}}
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'post'},  //if using get method body is not run then using post method.
    });

    Schoolmanagement.remoteMethod('getStudentData',{
        accepts: [{arg: 'studentId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getHeadmasterData',{
        accepts: [{arg: 'headmasterId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getTeacherData',{
        accepts: [{arg: 'teacherId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getSchoolData',{
        accepts: [{arg: 'schoolId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getStaffData',{
        accepts: [{arg: 'staffId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getClassData',{
        accepts: [{arg: 'classId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('addHeadMasterData', {
        accepts: [
            { arg: 'datah', type: 'headmaster', http: { source: 'body' } }
        ],
        returns: { type: 'headmaster', root: true }//headmaster
    });

    Schoolmanagement.remoteMethod('addStudentData', {
        accepts: [
            { arg: 'datast', type: 'student', http: { source: 'body' } }
        ],
        returns: { type: 'student', root: true }//student
    });

    Schoolmanagement.remoteMethod('addSchoolData', {
        accepts: [
            { arg: 'datas', type: 'school', http: { source: 'body' } }
        ],
        returns: { type: 'school', root: true }//school 
         //Array type hoga to error show hoga isliye string type rakhkar data add karte hai time use array mai karke hi add karte work karta hai
    });

    Schoolmanagement.remoteMethod('addStaffData', {
        accepts: [
            { arg: 'data', type: 'staff', http: { source: 'body' } }
        ],
        returns: { type: 'staff', root: true }//staff
    });

    Schoolmanagement.remoteMethod('addClassData', {
        accepts: [
            { arg: 'datac', type: 'class', http: { source: 'body' } }
        ],
        returns: { type: 'class', root: true }//class
    });

    Schoolmanagement.remoteMethod('addTeacherData', {
        accepts: [
            { arg: 'datat', type: 'teacher', http: { source: 'body' } }
        ],
        returns: { type: 'teacher', root: true }//teacher
    });
};


#Pagination using POST method because give a body

{
  "docType": "student",
  "pageSize": "10",
  "bookmark": ""
}
{
  "docType": "student",
  "bookmark": ""
} //if not give any pageSize byDefault using no. of 5 using

//localhost:3000/explorer/
run and update method
{
  "pageSize": "2",
  "bookmark": "g1AAAAA6eJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqzBod4GBiBJDlgkgjhLAC_9g9h"
}
------------------------------------------------------------------------------------------------------------------------------

   Schoolmanagement.remoteMethod('getStudentDataWithPagination',{
        accepts: [
            {arg: 'data',type: 'object'} //body also remove
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
        // If you are using get method then body is not run
    });
{ "pageSize": "3" , "bookmark": "g1AAAAA6eJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqzBod4GBiDJDlgkgjhLADAEQ9j" }  //get method is also working .

****************************************************************************************************************************************************************
=================================================================================================================================================================
****************************************************************************************************************************************************************
//Some Condition and restriction use :-

file inside Chaincode 

const state = require('./utils/state');
module.exports = {

async addHeadmaster(ctx,id,name,doj,degree){

    try{

        if(id.length === 0 ){
            console.log(".....................................................................................");
            console.log("Headmaster Id should be there");
            console.log("==============================================");
            throw "Headmaster Id must not be empty";
        } //This method check id is not empty if id empty then show throw data

        try {
            await state.keyMustNotExist(ctx, id);  //THis line using Id not Exist then create Id 
        
        } catch (error) {
            console.log(id)
            throw id + " Headmaster is already registered"
        }

        if(name.length === 0 ){
            console.log(".....................................................................................");
            console.log("Headmaster Name should be there");
            console.log("==============================================");
            throw "Headmaster Name must not be empty";
        }

        if(doj.length === 0 ){
            console.log(".....................................................................................");
            console.log("Headmaster joining date should be there");
            console.log("==============================================");
            throw "Headmaster joining date must not be empty";
        }

        if(degree.length === 0 ){
            console.log(".....................................................................................");
            console.log("Headmaster Degree should be there");
            console.log("==============================================");
            throw "Headmaster Degree must not be empty";
        }

        const addData = {
            id,
            name,
            doj,
            degree,
            docType: "headmaster"
        }
        await ctx.stub.putState(id,Buffer.from(JSON.stringify(addData)));
        return {
            status: true,
            data: id +" Headmaster added Successfully"
        };
}catch(error){
    return{
        status: false,
        data: error
    }
}
},

async addTeachers(ctx,teacherId,name,doj,degree,subject,classlist){
    try{

        classlist = JSON.parse(classlist); //because classlist is obj

        if(teacherId.length === 0 ){
            console.log(".....................................................................................");
            console.log("Teacher TeacherId should be there");
            console.log("==============================================");
            throw "Teacher TeacherId must not be empty";
        }        

        try {
            await state.keyMustNotExist(ctx, teacherId);
        
        } catch (error) {
            console.log(teacherId)
            throw teacherId + " Teacher is already registered"
        }

        if(name.length === 0 ){
            console.log(".....................................................................................");
            console.log("Teacher Name should be there");
            console.log("==============================================");
            throw "Teacher Name must not be empty";
        }

        if(doj.length === 0 ){
            console.log(".....................................................................................");
            console.log("Teacher Joining date should be there");
            console.log("==============================================");
            throw "Teacher Joining date should be there";
        }

        if(degree.length === 0 ){
            console.log(".....................................................................................");
            console.log("Teacher degree should be there");
            console.log("==============================================");
            throw "Teacher Degree must not be empty";
        }

        if(subject.length === 0 ){
            console.log(".....................................................................................");
            console.log("Teacher name should be there");
            console.log("==============================================");
            throw "Teacher Subject must not be empty";
        }

        if(classlist.length === 0 ){
            console.log(".....................................................................................");
            console.log("Teacher classlist should be there");
            console.log("==============================================");
            throw "Teacher Classlist must not be empty";
        }

        const addTeacher = {
            teacherId,
            name,
            doj,
            degree,
            subject,
            classlist,
            docType: "teacher"
        }
        await ctx.stub.putState(teacherId,Buffer.from(JSON.stringify(addTeacher)));
        return {
            status: true,
            data: teacherId + " Teacher added Successfully"
        }
}catch(error){
    console.log(error);
    return{
        status: false,
        data: error
    }
}
},

async addClass(ctx,classId,studentList,subjectList){
    try{
        studentList = JSON.parse(studentList);
        subjectList = JSON.parse(subjectList);

        if(classId.length === 0 ){
            console.log(".....................................................................................");
            console.log(" ClassId should be there");
            console.log("==============================================");
            throw " ClassId must not be empty";
        } 
        
        try {
            await state.keyMustNotExist(ctx, classId);
        
        } catch (error) {
            console.log(classId)
            throw classId + " Class is already registered"
        }

        if(studentList.length === 0 ){
            console.log(".....................................................................................");
            console.log("StudentList should be there");
            console.log("==============================================");
            throw "StudentList must not be empty";
        } 

        if(subjectList.length === 0 ){
            console.log(".....................................................................................");
            console.log("SubjectList should be there");
            console.log("==============================================");
            throw "SubjectList must not be empty";
        } 

        const addClassData = {
            classId,
            studentList,
            subjectList,
            docType: "class"
        }
        await ctx.stub.putState(classId,Buffer.from(JSON.stringify(addClassData)));
        return {
            status: true,
            data: classId + " Class data added Successfully"
        }
}catch(error){
    return{
        status: false,
        data: error
    }
}
},

async addStuff(ctx,staffId,name,doj,degree,department){

    try{

        if(staffId.length === 0 ){
            console.log(".....................................................................................");
            console.log("StaffId should be there");
            console.log("==============================================");
            throw "StaffId must not be empty";
        } 
        
        try {
            await state.keyMustNotExist(ctx, staffId);
        
        } catch (error) {
            console.log(staffId)
            throw staffId + " Staff is already registered"
        }

        if(name.length === 0 ){
            console.log(".....................................................................................");
            console.log("Staff Name should be there");
            console.log("==============================================");
            throw "Staff Name must not be empty";
        } 

        if(doj.length === 0 ){
            console.log(".....................................................................................");
            console.log("Staff Joining date should be there");
            console.log("==============================================");
            throw "Staff Joining date must not be empty";
        } 

        if(degree.length === 0 ){
            console.log(".....................................................................................");
            console.log("Staff Degree should be there");
            console.log("==============================================");
            throw "Staff Degree must not be empty";
        } 

        if(department.length === 0 ){
            console.log(".....................................................................................");
            console.log("Staff Department should be there");
            console.log("==============================================");
            throw "Staff Department must not be empty";
        } 

        const addStaffData = {
            staffId,
            name,
            doj,
            degree,
            department,
            docType: "teacher"
        }
        await ctx.stub.putState(staffId,Buffer.from(JSON.stringify(addStaffData)));
        return {
            status: true,
            data: staffId + " Staff Teacher added Successfully"
        }
}catch(error){
    return{
        status: false,
        data: error
    }
}
},
async addSchoolData(ctx,schoolId,name,city,headmaster,teachers,address){
    try{
        teachers = JSON.parse(teachers);

        if(schoolId.length === 0 ){
            console.log(".....................................................................................");
            console.log("School Id should be there");
            console.log("==============================================");
            throw "School Id must not be empty";
        }

        try {
            await state.keyMustNotExist(ctx, schoolId);
        
        } catch (error) {
            console.log(schoolId)
            throw schoolId + " Schhol is already registered"
        }

        if(name.length === 0 ){
            console.log(".....................................................................................");
            console.log("School Name should be there");
            console.log("==============================================");
            throw "School Name must not be empty";
        }

        if(city.length === 0 ){
            console.log(".....................................................................................");
            console.log("School City should be there");
            console.log("==============================================");
            throw "School City must not be empty";
        }

        if(headmaster.length === 0 ){
            console.log(".....................................................................................");
            console.log("School Headmaster Id should be there");
            console.log("==============================================");
            throw "School Headmaster Id must not be empty";
        }

        if(teachers.length === 0 ){
            console.log(".....................................................................................");
            console.log("School Teachers Id should be there");
            console.log("==============================================");
            throw "School Teachers Id must not be empty";
        }

        if(address.length === 0 ){
            console.log(".....................................................................................");
            console.log("School Address should be there");
            console.log("==============================================");
            throw "School Address must not be empty";
        }

        const addSchoolData = {
            schoolId,
            name,
            city,
            headmaster,
            teachers,
            address,
            docType: "school"
        }
        await ctx.stub.putState(schoolId,Buffer.from(JSON.stringify(addSchoolData)));
        return {
            status: true,
            data: schoolId + " SchoolData added Successfully"
        }
}catch(error){
    return{
        status: false,
        data: error
    }
}
},
async addStudent(ctx,studentId,name,DOB,classs,sex,address){

    try{

        if(studentId.length === 0 ){
            console.log(".....................................................................................");
            console.log("StudentId should be there");
            console.log("==============================================");
            throw "StudentId must not be empty";
        }

        try {
            await state.keyMustNotExist(ctx, studentId);
        
        } catch (error) {
            console.log(studentId)
            throw studentId + " Student is already registered"
        }

        if(name.length === 0 ){
            console.log(".....................................................................................");
            console.log("Student Name should be there");
            console.log("==============================================");
            throw "Student Name must not be empty";
        }

        if(DOB.length === 0 ){
            console.log(".....................................................................................");
            console.log("Student Date of Birth should be there");
            console.log("==============================================");
            throw "Student Date of Birth must not be empty";
        }

        if(classs.length === 0 ){
            console.log(".....................................................................................");
            console.log("Student Class should be there");
            console.log("==============================================");
            throw "Student Class must not be empty";
        }

        if(sex.length === 0 ){
            console.log(".....................................................................................");
            console.log("Student Sex should be there");
            console.log("==============================================");
            throw "Student Sex must not be empty";
        }

        if(address.length === 0 ){
            console.log(".....................................................................................");
            console.log("Student Address should be there");
            console.log("==============================================");
            throw "Student Address must not be empty";
        }

        const addStudentData = {
            studentId,
            name,
            DOB,
            classs,
            sex,
            address,
            docType: "student"
        }
        await ctx.stub.putState(studentId,Buffer.from(JSON.stringify(addStudentData)));
        return {
            status: true,
            data: studentId + " Student added Successfully"
        }
}catch(error){
    return{
        status: false,
        data: error
    }
}
}
}


Api file inside client/model

'use strict';

const escapeJson = require('escape-json-node/lib/escape-json'); 
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Schoolmanagement) {

    let defineHeadmasterFormat = function(){
        let headMasterModel = {
            'id' : String,
            'name' : String,
            'doj' : String,
            'degree' : String
        };
        ds.define('headmaster',headMasterModel);
    };
    defineHeadmasterFormat();  

    let defineTeacherFormat = function(){
        let headTeacherModel = {
            'teacherId' : String,
            'name' : String,
            'doj' : String,
            'degree' : String,
            'subject' : String,
            'classlist' : String  //Array to String convert because you are not convert your data is not visible
        };
        ds.define('teacher',headTeacherModel);
    };
    defineTeacherFormat();

    let defineClassFormat = function(){
        let headClassModel = {
            'classId' : String,
            'studentList' : String,  //Array to String convert because you are not convert your data is not visible
            'subjectList' : String  //Array to String convert because you are not convert your data is not visible
        };
        ds.define('class',headClassModel);
    };
    defineClassFormat();

    let defineStaffFormat = function(){
        let headStaffModel = {
            'staffId' : String,
            'name' : String,
            'doj' : String,
            'degree' : String,
            'department' : String
        };
        ds.define('staff',headStaffModel);
    };
    defineStaffFormat();

    let defineSchoolFormat = function(){
        let headSchoolModel = {
            'schoolId' : String,
            'name' : String,
            'city' : String,
            'headmaster' : String,
            'teachers' : String, //Array to String convert because you are not convert your data is not visible
            'address' : String
        };
        ds.define('school',headSchoolModel);
    };
    defineSchoolFormat();

    let defineStudentFormat = function(){
        let headStudentModel = {
            'studentId' : String,
            'name' : String,
            'DOB' : String,
            'classs' : String,
            'sex' : String,
            'address' : String
        };
        ds.define('student',headStudentModel);
    };
    defineStudentFormat();

    Schoolmanagement.addHeadMasterData = async function (datah){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
          'addHeadmaster',
          datah.id,
          datah.name,
          datah.doj,
          datah.degree  
        );
        result = JSON.parse(result.toString()) ;
        //This above line is very important because this line not use responce data show base64 this is not understaning, so converted 
        return result;
    }

    Schoolmanagement.addTeacherData = async function(datat){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addTeacher',
            datat.teacherId,
            datat.name,
            datat.doj,
            datat.degree,
            datat.subject,
            escapeJson(JSON.stringify(datat.classlist))
        );
        result = JSON.parse(result.toString()) ;
        //This above line is very important because this line not use responce data show base64 this is not understaning, so converted 
        return result;
    }

    Schoolmanagement.addClassData = async function(datac){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addClass',
            datac.classId,
            escapeJson(JSON.stringify(datac.studentList)),
            escapeJson(JSON.stringify(datac.subjectList))
        );
        result = JSON.parse(result.toString()) ;
        return result;
    }

    Schoolmanagement.addStaffData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addStaff',
            data.staffId,
            data.name,
            data.doj,
            data.degree,
            data.department
            );
            result = JSON.parse(result.toString()) ;
            return result;
    }

    Schoolmanagement.addSchoolData  = async function(datas){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addSchoolData',
            datas.schoolId,
            datas.name,
            datas.city,
            datas.headmaster,
            escapeJson(JSON.stringify(datas.teachers)),
            datas.address
        );
        result = JSON.parse(result.toString()) ;
        return result
    }

    Schoolmanagement.addStudentData = async function(datast){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addStudent',
            datast.studentId,
            datast.name,
            datast.DOB,
            datast.classs,
            datast.sex,
            datast.address
        );
        result = JSON.parse(result.toString()) ;
        return result
    }

    Schoolmanagement.getStudentDataWithPagination = async function(data){
        console.log(data);
        const contract = await chaincode.validateUser('user3')
        let filterObject = {
            "docType": "student"
        }
        filterObject = escapeJson(JSON.stringify(filterObject));

        if(data.bookmark === undefined){
            data.bookmark = "";
        }

        if(data.pageSize === undefined){
            data.pageSize = "5";
        }
        var result = await contract.evaluateTransaction(
            'filterDataWithPagination',
            filterObject,
            data.pageSize,
            data.bookmark
        );
        return JSON.parse(result.toString());
    }

    Schoolmanagement.getStudentData = async function(studentId){
        const contract = await chaincode.validateUser('user3')

        var studentResult = await contract.evaluateTransaction('queryState',studentId);
        studentResult = JSON.parse(studentResult.toString());
        return studentResult;
    }

    Schoolmanagement.getTeacherData = async function(teacherId){
        const contract = await chaincode.validateUser('user3')

        var teacherResult = await contract.evaluateTransaction('queryState',teacherId);
        teacherResult = JSON.parse(teacherResult.toString());
        return teacherResult;
    }

    Schoolmanagement.getHeadmasterData = async function(headmasterId){
        const contract = await chaincode.validateUser('user3')

        var headmasterResult = await contract.evaluateTransaction('queryState',headmasterId);
        headmasterResult = JSON.parse(headmasterResult.toString());
        return headmasterResult;
    }

    Schoolmanagement.getStaffData = async function(staffId){
        const contract = await chaincode.validateUser('user3')

        var staffResult = await contract.evaluateTransaction('queryState',staffId);
        staffResult = JSON.parse(staffResult.toString());
        return staffResult;
    }

    Schoolmanagement.getSchoolData = async function(schoolId){
        const contract = await chaincode.validateUser('user3')

        var schoolResult = await contract.evaluateTransaction('queryState',schoolId);
        schoolResult = JSON.parse(schoolResult.toString());
        return schoolResult;
    }

    Schoolmanagement.getClassData = async function(classId){
        const contract = await chaincode.validateUser('user3')

        var classResult = await contract.evaluateTransaction('queryState',classId);
        classResult = JSON.parse(classResult.toString());
        return classResult;
    }

    Schoolmanagement.remoteMethod('getStudentDataWithPagination',{
        accepts: [
            {arg: 'data',type: 'object'}
        ],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
        // If you are using get method then body is not run , so remove the body and run this method also running
    });

    Schoolmanagement.remoteMethod('getStudentData',{
        accepts: [{arg: 'studentId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getHeadmasterData',{
        accepts: [{arg: 'headmasterId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getTeacherData',{
        accepts: [{arg: 'teacherId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getSchoolData',{
        accepts: [{arg: 'schoolId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getStaffData',{
        accepts: [{arg: 'staffId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('getClassData',{
        accepts: [{arg: 'classId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Schoolmanagement.remoteMethod('addHeadMasterData', {
        accepts: [
            { arg: 'datah', type: 'headmaster', http: { source: 'body' } }
        ],
        returns: { type: 'headmaster', root: true }//headmaster
    });

    Schoolmanagement.remoteMethod('addStudentData', {
        accepts: [
            { arg: 'datast', type: 'student', http: { source: 'body' } }
        ],
        returns: { type: 'student', root: true }//student
    });

    Schoolmanagement.remoteMethod('addSchoolData', {
        accepts: [
            { arg: 'datas', type: 'school', http: { source: 'body' } }
        ],
        returns: { type: 'school', root: true }//school 
         //Array type hoga to error show hoga isliye string type rakhkar data add karte hai time use array mai karke hi add karte work karta hai
    });

    Schoolmanagement.remoteMethod('addStaffData', {
        accepts: [
            { arg: 'data', type: 'staff', http: { source: 'body' } }
        ],
        returns: { type: 'staff', root: true }//staff
    });

    Schoolmanagement.remoteMethod('addClassData', {
        accepts: [
            { arg: 'datac', type: 'class', http: { source: 'body' } }
        ],
        returns: { type: 'class', root: true }//class
    });

    Schoolmanagement.remoteMethod('addTeacherData', {
        accepts: [
            { arg: 'datat', type: 'teacher', http: { source: 'body' } }
        ],
        returns: { type: 'teacher', root: true }//teacher
    });
};



//realmeds.js file in chaincode

const Schoolmanagement = require('./schoolManagement')

    async queryState(ctx, key) {
        try {
            var result = await state.keyMustExist(ctx, key);
            return result;
        } catch (error) {
            return "not found";
        }//data get karne wale method ka method hai
    }

    async addHeadmaster(ctx,id,name,doj,degree){
        let response = await Schoolmanagement.addHeadmaster(ctx,id,name,doj,degree);
        return response
    }

    async addTeacher(ctx,teacherId,name,doj,degree,subject,classlist){
        let response = await Schoolmanagement.addTeachers(ctx,teacherId,name,doj,degree,subject,classlist);
        return response
    }

    async addClass(ctx,classId,studentList,subjectList){
        let response = await Schoolmanagement.addClass(ctx,classId,studentList,subjectList);
        return response
    }

    async addStaff(ctx,staffId,name,doj,degree,department){
        let response = await Schoolmanagement.addStuff(ctx,staffId,name,doj,degree,department);
        return response
    }

    async addSchoolData(ctx,schoolId,name,city,headmaster,teachers,address){
        let response = await Schoolmanagement.addSchoolData(ctx,schoolId,name,city,headmaster,teachers,address);
        return response
    }

    async addStudent(ctx,studentId,name,DOB,classs,sex,address){
        let response = await Schoolmanagement.addStudent(ctx,studentId,name,DOB,classs,sex,address);
        return response
    }

    //This below method using Pagination method running:-

    async filterDataWithPagination(ctx, filterObj, pageSize, bookmark) {

        filterObj = JSON.parse(filterObj);

        var queryString = {};
        queryString.selector = {};

        queryString.selector = { ...filterObj };

        var response = {};

        pageSize = parseInt(pageSize, 10);

        let peginationResponse = await ctx.stub.getQueryResultWithPagination(JSON.stringify(queryString), pageSize, bookmark);
        const { iterator, metadata } = peginationResponse;

        let keyList = await state.getAllResultsOfPagination(iterator);

        response["success"] = [];
        response["metadata"] = metadata;

        for (let index = 0; index < keyList.length; index++) {
            const key = keyList[index];

            var data = await state.keyMustExist(ctx, key);
            var result = {};
            result["Key"] = key;
            result["Record"] = data;
            response["success"].push(result);
        }

        var totalKeyCntIterator = await state.query(ctx, queryString);
        var keyCnt = await state.keyCount(totalKeyCntIterator);
        keyCnt = JSON.parse(keyCnt);

        response["metadata"]["totalCount"] = keyCnt.length;
        return response;
    }

    //update user data 
//chaincode ke under file hota hai

      async updateTeacherData(ctx,teacherId,children){
        try{
            children = JSON.parse(children);
    
            if(teacherId.length === 0 ){
                throw "TeacherId must not be empty";
            } 
            try{
               var teacherUserData = await state.keyMustExist(ctx,teacherId);

            }catch(error){
                throw 'invalid TeacherId ' +teacherId;
            }

            // if(teacherUserData.name && teacherUserData.name.length === 0 ){
            //     throw "Name must not be empty";
            // }

            // if(teacherUserData.doj && teacherUserData.doj.length === 0 ){
            //     throw "Date of Joining must not be empty";
            // }

            // if(teacherUserData.degree && teacherUserData.degree.length === 0 ){
            //     throw "Degree must not be empty";
            // }

            // if(teacherUserData.subject && teacherUserData.subject.length === 0 ){
            //     throw "Subject must not be empty";
            // }

            // if(teacherUserData.classlist && teacherUserData.classlist.length === 0 ){
            //     throw "ClassList must not be empty";
            // }//This method is not using also proper working

            if(children.name){
                teacherUserData.name = children.name;
            }

            if(children.doj){
                teacherUserData.doj = children.doj;
            }

            if(children.degree){
                teacherUserData.degree = children.degree;
            }

            if(children.subject){
                teacherUserData.subject = children.subject;
            }

            if(children.classlist){
                teacherUserData.classlist = children.classlist;
            }

            await ctx.stub.putState(teacherId, Buffer.from(JSON.stringify(teacherUserData)));

            return{
                status : true,
                data :  teacherId +" updated successfully"
            }

        }catch(error){
            return{
                status: false,
                data: error
            }
        }
    }

//realmeds.js file

  async updateTeachersData(ctx,teacherId,children) {
        return await teachers.updateTeacherData(ctx,teacherId,children)
    }

//Api teacher.js file    

    Teacher.updateTeacherData = async function(data){
        try{
        const contract = await chaincode.validateUser('user3')
        
        var teachersId = data.teacherId;
        data = escapeJson(JSON.stringify(data));

        var responce = await contract.submitTransaction(
            'updateTeachersData',
            teachersId,
            data
        );

        return JSON.parse(responce.toString());

        -- if(responce.status){
        --     return responce.data;
        -- }else{
        --     throw new Error(responce.data)
        -- }
    }catch(error){
        throw error;
    }
    }

    Teacher.remoteMethod('updateTeacherData', {
        accepts: [
            { arg: 'data', type: 'teacher', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'}
    });


    =========================================================================================================================================================
    //some update details like you direct search in techer and syudent field to specific school data

    chaincode/lib/Studentmanagement/techer.js

    const state = require('../utils/state');
module.exports = {

    async addTeachers(ctx,teacherId,name,doj,degree,subject,classlist,schoolId){
        try{
    
            classlist = JSON.parse(classlist); //because classlist is obj
    
            if(teacherId.length === 0 ){
                console.log(".....................................................................................");
                console.log("Teacher TeacherId should be there");
                console.log("==============================================");
                throw "Teacher TeacherId must not be empty";
            }        
    
            try {
                await state.keyMustNotExist(ctx, teacherId);
            
            } catch (error) {
                console.log(teacherId)
                throw teacherId + " Teacher is already registered"
            }
    
            if(name.length === 0 ){
                console.log(".....................................................................................");
                console.log("Teacher Name should be there");
                console.log("==============================================");
                throw "Teacher Name must not be empty";
            }
    
            if(doj.length === 0 ){
                console.log(".....................................................................................");
                console.log("Teacher Joining date should be there");
                console.log("==============================================");
                throw "Teacher Joining date should be there";
            }
    
            if(degree.length === 0 ){
                console.log(".....................................................................................");
                console.log("Teacher degree should be there");
                console.log("==============================================");
                throw "Teacher Degree must not be empty";
            }
    
            if(subject.length === 0 ){
                console.log(".....................................................................................");
                console.log("Teacher name should be there");
                console.log("==============================================");
                throw "Teacher Subject must not be empty";
            }
    
            if(classlist.length === 0 ){
                console.log(".....................................................................................");
                console.log("Teacher classlist should be there");
                console.log("==============================================");
                throw "Teacher Classlist must not be empty";
            }

            if(schoolId.length ===0){
                throw "Teacher inside schoolId not empty"
            }
    
            const addTeacher = {
                teacherId,
                name,
                doj,
                degree,
                subject,
                classlist,
                schoolId,
                docType: "teacher"
            }
            await ctx.stub.putState(teacherId,Buffer.from(JSON.stringify(addTeacher)));
            return {
                status: true,
                data: teacherId + " Teacher added Successfully"
            }
    }catch(error){
        console.log(error);
        return{
            status: false,
            data: error
        }
    }
    },

    async updateTeacherData(ctx,teacherId,children){
        try{
            children = JSON.parse(children);
    
            if(teacherId.length === 0 ){
                throw "TeacherId must not be empty";
            } 
            try{
               var teacherUserData = await state.keyMustExist(ctx,teacherId);

            }catch(error){
                throw 'invalid TeacherId ' +teacherId;
            }

            // if(teacherUserData.name && teacherUserData.name.length === 0 ){
            //     throw "Name must not be empty";
            // }

            // if(teacherUserData.doj && teacherUserData.doj.length === 0 ){
            //     throw "Date of Joining must not be empty";
            // }

            // if(teacherUserData.degree && teacherUserData.degree.length === 0 ){
            //     throw "Degree must not be empty";
            // }

            // if(teacherUserData.subject && teacherUserData.subject.length === 0 ){
            //     throw "Subject must not be empty";
            // }

            // if(teacherUserData.classlist && teacherUserData.classlist.length === 0 ){
            //     throw "ClassList must not be empty";
            // }//This method is not using also proper working

            if(children.name){
                teacherUserData.name = children.name;
            }

            if(children.doj){
                teacherUserData.doj = children.doj;
            }

            if(children.degree){
                teacherUserData.degree = children.degree;
            }

            if(children.subject){
                teacherUserData.subject = children.subject;
            }

            if(children.classlist){
                teacherUserData.classlist = children.classlist;
            }

            if(children.schoolId){
                teacherUserData.schoolId = children.schoolId;
            }

            await ctx.stub.putState(teacherId, Buffer.from(JSON.stringify(teacherUserData)));

            return{
                status : true,
                data :  teacherId +" updated successfully"
            }

        }catch(error){
            return{
                status: false,
                data: error
            }
        }
    }

    // async updateTeacherData(ctx,teacherId,name,doj,degree,subject,classlist){
    //     try{

    //         if(teacherId.length === 0 ){
    //             throw "Teacher TeacherId must not be empty";
    //         } 
    //         try{
    //             await state.keyMustExist(ctx,teacherId);

    //         }catch(error){
    //             throw 'invalid userId ' +teacherId;
    //         }
    //         classlist = JSON.parse(classlist);

    //         if(name.length === 0 ){
    //             throw "Teacher Name must not be empty";
    //         }
    
    //         if(doj.length === 0 ){
    //             throw "Teacher Joining date should be there";
    //         }
    
    //         if(degree.length === 0 ){
    //             throw "Teacher Degree must not be empty";
    //         }
    
    //         if(subject.length === 0 ){
    //             throw "Teacher Subject must not be empty";
    //         }
    
    //         if(classlist.length === 0 ){
    //             throw "Teacher Classlist must not be empty";
    //         }
    //         const userDetails = {
    //             name,
    //             doj,
    //             degree,
    //             subject,
    //             classlist,
    //             docType : "teacher"
    //         }
    //         await ctx.stub.putState(teacherId,Buffer.from(JSON.stringify(userDetails)));
    //         return {
    //             status: true,
    //             data: teacherId + " id updated Successfully"
    //         }
    // }catch(error){
    //     return {
    //         status: false,
    //         data: error
    //     }
    // }//This method using all data updated one single time.
    // }
}

chaincode/lib/realmeds.js

 async addTeachers(ctx,teacherId,name,doj,degree,subject,classlist,schoolId){
        let response = await teacher.addTeachers(ctx,teacherId,name,doj,degree,subject,classlist,schoolId);
        return response
    }
  async updateTeachersData(ctx,teacherId,children) {
        return await teachers.updateTeacherData(ctx,teacherId,children)
    }


api/comman/model/teacher.js

'use strict';

const escapeJson = require('escape-json-node/lib/escape-json'); 
const chaincode = require('../../lib/validate-user');
const loopback = require('loopback');
const ds = loopback.createDataSource('memory'); 

module.exports = function(Teacher) {

    let defineTeacherFormat = function(){
        let headTeacherModel = {
            'teacherId' : String,
            'name' : String,
            'doj' : String,
            'degree' : String,
            'subject' : String,
            'classlist' : String,  //Array to String convert because you are not convert your data is not visible
            'schoolId' : String
        };
        ds.define('teacher',headTeacherModel);
    };
    defineTeacherFormat();

    Teacher.addTeacherData = async function(data){
        const contract = await chaincode.validateUser('user3')
        let result = await contract.submitTransaction(
            'addTeachers',
            data.teacherId,
            data.name,
            data.doj,
            data.degree,
            data.subject,
            escapeJson(JSON.stringify(data.classlist)),
            data.schoolId
        );
        return JSON.parse(result.toString()) ;
    }

    Teacher.getTeacherData = async function(teacherId){
        const contract = await chaincode.validateUser('user3')

        var teacherResult = await contract.evaluateTransaction('queryState',teacherId);
       return JSON.parse(teacherResult.toString());
    }

    // Teacher.updateTeacherDatas = async function(updateData){
    //     const contract = await chaincode.validateUser('user3')
    //     let updateResult = await contract.submitTransaction(
    //         'updateTeacherData',
    //         updateData.teacherId,
    //         updateData.name,
    //         updateData.doj,
    //         updateData.degree,
    //         updateData.subject,
    //         escapeJson(JSON.stringify(updateData.classlist))
    //     );
    //     return JSON.parse(updateResult.toString());
    // }//This method using all data updated one single time.

    Teacher.updateTeacherData = async function(data){
        try{
        const contract = await chaincode.validateUser('user3')
        
        var teachersId = data.teacherId;
        data = escapeJson(JSON.stringify(data));

        var responce = await contract.submitTransaction(
            'updateTeachersData',
            teachersId,
            data
        );

        return JSON.parse(responce.toString());
    }catch(error){
        throw error;
    }
    }

    Teacher.remoteMethod('updateTeacherData', {
        accepts: [
            { arg: 'data', type: 'teacher', http: { source: 'body' } }
        ],
        returns: { type: 'object', root: true },
        http: {verb: 'put'}
    });

    Teacher.remoteMethod('getTeacherData',{
        accepts: [{arg: 'teacherId',type: 'string'}],
        returns: {type: 'object', root: true},
        http: {verb: 'get'},
    });

    Teacher.remoteMethod('addTeacherData', {
        accepts: [
            { arg: 'data', type: 'teacher', http: { source: 'body' } }
        ],
        returns: { type: 'teacher', root: true }
    });
};

===========================================================================================================================================================   