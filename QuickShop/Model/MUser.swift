//
//  MUser.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-21.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation
import FirebaseAuth

class MUser {
    
    let objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItemsIds: [String]
    var fullAddress: String?
    var onBoard: Bool
    
    init(objectId: String, email: String, firstName: String, lastName: String) {
        
        self.objectId = objectId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        fullName = firstName + "" + lastName
        fullAddress = ""
        onBoard = false
        purchasedItemsIds = []
    }
    
    init(dictionary: NSDictionary) {
        
        objectId = dictionary[Constants.K.id] as! String
        
        if let mail = dictionary[Constants.K.user.email] {
            email = mail as! String
        }
        else {
            email = ""
        }
        
        if let fName = dictionary[Constants.K.user.firstName] {
            firstName = fName as! String
        }
        else {
            firstName = ""
        }
        
        if let lName = dictionary[Constants.K.user.lastName] {
            lastName = lName as! String
        }
        else {
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let fAddress = dictionary[Constants.K.user.fullAddress] {
            fullAddress = (fAddress as! String)
        }
        else {
            fullAddress = ""
        }
        
        if let onB = dictionary[Constants.K.user.onBoard] {
            onBoard = onB as! Bool
        }
        else {
            onBoard = false
        }
        
        if let pIds = dictionary[Constants.K.user.purchasedItems] {
            purchasedItemsIds = pIds as! [String]
        }
        else {
            purchasedItemsIds = []
        }
    }
    
    //MARK:- return current User
    
    //if user exist, it return user Id
    class func currentId() -> String {
        
        return Auth.auth().currentUser!.uid
    }
    
    //for check authenticate users
    class func currentUser() -> MUser? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: Constants.K.user.currentUser) {
                return MUser.init(dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }
    
    //MARK:- login function
    class func loginUserWith(email:String, password: String, completion: @escaping(_ error: Error?, _ isEmailVerified: Bool)->Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil {
                //check weather email is verified or not
                if authDataResult!.user.isEmailVerified {
                    //download user from firestore
                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
                    completion(error,true)
                }
                else {
                    print("email is not verified!")
                    completion(error,false)
                }
            }
            else {
                completion(error,false)
            }
        }
    }
    //MARK:- register user
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?)->Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            if error == nil {
                
                //send verification email
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email verification error: ", error?.localizedDescription)
                }
            }
        }
    }
    //MARK:- resend link
    class func resetPassword(email: String, completion: @escaping(_ error: Error?)->Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            completion(error)
        }
    }
    // resend verification email
    class func resendVerificationEmail(email: String, completion: @escaping(_ error: Error?)->Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                
                print("resend email error: ", error!.localizedDescription)
                completion(error)
            })
        })
    }
    
    class func logoutCurrentUser(completion: @escaping (_ error: Error?)-> Void) {
        
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: Constants.K.user.currentUser)
            UserDefaults.standard.synchronize()
            completion(nil)
        }
        catch let error as NSError {
            completion(error)
        }

    }
}
//MARK:- download user from firebase
func downloadUserFromFirestore(userId: String, email: String) {
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            return
        }
        if snapshot.exists {
            print("download current user from firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        }
        else {
            //save new user in firestore
            let user = MUser(objectId: userId, email: email, firstName: "", lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
    }
}
//MARK:- save user to firebase
func saveUserToFirestore(mUser: MUser) {
    
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String : Any]) { (error) in
        if error != nil {
            print("error saving user \(error!.localizedDescription)")
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary) {
    
    UserDefaults.standard.set(mUserDictionary, forKey: Constants.K.user.currentUser)
    UserDefaults.standard.synchronize()
}

//MARK:- helper function
func userDictionaryFrom(user : MUser) -> NSDictionary {
    
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName,user.fullAddress ?? "", user.onBoard, user.purchasedItemsIds], forKeys: [Constants.K.id as NSCopying, Constants.K.user.email as NSCopying, Constants.K.user.firstName as NSCopying, Constants.K.user.lastName as NSCopying, Constants.K.user.fullName as NSCopying, Constants.K.user.fullAddress as NSCopying, Constants.K.user.onBoard as NSCopying, Constants.K.user.purchasedItems as NSCopying])
}

//MARK:- update user
func updateUserInFirestore(withValues: [String: Any], completion: @escaping (_ error: Error?)->Void){
    
    if let dictionary = UserDefaults.standard.object(forKey: Constants.K.user.currentUser) {
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
        userObject.setValuesForKeys(withValues)
        FirebaseReference(.User).document(MUser.currentId()).updateData(withValues) {
            (error) in
            completion(error)
            
            if error == nil {
                saveUserLocally(mUserDictionary: userObject)
            }
        }
    }
}


