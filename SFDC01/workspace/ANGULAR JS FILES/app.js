/**
 * Describe Salesforce object to be used in the app. For example: Below AngularJS factory shows how to describe and
 * create an 'Contact' object. And then set its type, fields, where-clause etc.
 *
 *  PS: This module is injected into ListCtrl, EditCtrl etc. controllers to further consume the object.
 */
angular.module('Contact', []).factory('Contact', function (AngularForceObjectFactory) {
    //Describe the contact object
    var objDesc = {
        type: 'Contact',
        fields: ['FirstName', 'LastName', 'Title', 'Phone', 'Email', 'Id', 'Account.Name'],
        where: '',
        orderBy: 'LastName',
        limit: 20
    };
    var Contact = AngularForceObjectFactory(objDesc);

    return Contact;
});

angular.module('Account', []).factory('Account', function (AngularForceObjectFactory) {
    //Describe the account object
    var objDesc1 = {
        type: 'Account',
        fields: ['Name', 'NameLocal', 'Address__c', 'Phone', 'Party_Number__c', 'Id', 'Map_Account_Name__c'],
        where: '',
        orderBy: 'Name',
        limit: 20
    };
    var Account = AngularForceObjectFactory(objDesc1);

    return Account;
});

function HomeCtrl($scope, AngularForce, $location, $route) {

    $scope.authenticated = AngularForce.authenticated();
    if (!$scope.authenticated) {
        if (AngularForce.inVisualforce) {
            AngularForce.login();
        } else {
            return $location.path('/login');
        }
    }

    $scope.viewContacts = function() {
        console.log("HomeCtrl go to contacts...");
        $location.path('/contacts');
    }
    $scope.viewAccounts = function() {
        console.log("HomeCtrl go to accounts...");
        $location.path('/accounts');
    }

    $scope.logout = function () {
        AngularForce.logout();
        $location.path('/login');
    }
}

function LoginCtrl($scope, AngularForce, $location) {
    $scope.login = function () {
        AngularForce.login();
    }

    if (AngularForce.inVisualforce) {
        AngularForce.login();
        console.log("LoginCtrl just authenticated go to /");
        $location.path('/');
    }
}

function CallbackCtrl($scope, AngularForce, $location) {
    AngularForce.oauthCallback(document.location.href);
    $location.path('/contacts');
}

function ContactListCtrl($scope, AngularForce, $location, Contact) {
    $scope.authenticated = AngularForce.authenticated();
    if (!$scope.authenticated) {
        return $location.path('/login');
    }

    $scope.searchTerm = '';
    $scope.working = false;

    Contact.query(function (data) {
        $scope.contacts = data.records;
        //$scope.accounts = data.records;
        $scope.$apply();//Required coz sfdc uses jquery.ajax
    }, function (data) {
        alert('Query Error');
    });

   /* Account.query(function (data) {
        $scope.accounts = data.records;
        //$scope.accounts = data.records;
        $scope.$apply();//Required coz sfdc uses jquery.ajax
    }, function (data) {
        alert('Account Query Error');
    });*/

    $scope.isWorking = function () {
        return $scope.working;
    };

    $scope.doSearch = function () {
        Contact.search($scope.searchTerm, function (data) {
            $scope.contacts = data;
            $scope.$apply();//Required coz sfdc uses jquery.ajax
        }, function (data) {
        });
    };
    $scope.doSearchAccount = function () {
        Account.search($scope.searchTerm, function (data) {
            $scope.accounts = data;
            $scope.$apply();//Required coz sfdc uses jquery.ajax
        }, function (data) {
        });
    };

    $scope.doView = function (contactId) {
        console.log('doView');
        $location.path('/view/' + contactId);
    };

    $scope.doCreate = function () {
        $location.path('/new');
    }
}

function AccountListCtrl($scope, AngularForce, $location, Account) {
    $scope.authenticated = AngularForce.authenticated();
    if (!$scope.authenticated) {
        return $location.path('/login');
    }

    $scope.searchTerm = '';
    $scope.working = false;


     Account.query(function (data) {
     $scope.accounts = data.records;
     //$scope.accounts = data.records;
     $scope.$apply();//Required coz sfdc uses jquery.ajax
     }, function (data) {
     alert('Account Query Error');
     });

    $scope.isWorking = function () {
        return $scope.working;
    };

    $scope.doSearch = function () {
        Account.search($scope.searchTerm, function (data) {
            $scope.accounts = data;
            $scope.$apply();//Required coz sfdc uses jquery.ajax
        }, function (data) {
        });
    };


    $scope.doView = function (accountId) {
        console.log('doView');
        $location.path('/viewaccountdetail/' + accountId);
    };

    $scope.doCreate = function () {
        $location.path('/new');
    }
}



function ContactCreateCtrl($scope, $location, Contact) {
    $scope.save = function () {
        Contact.save($scope.contact, function (contact) {
            var c = contact;
            $scope.$apply(function () {
                $location.path('/view/' + c.Id);
            });
        });
    }
}

function ContactViewCtrl($scope, AngularForce, $location, $routeParams, Contact) {

    AngularForce.login(function () {
        Contact.get({id: $routeParams.contactId}, function (contact) {
            self.original = contact;
            $scope.contact = new Contact(self.original);
            $scope.$apply();//Required coz sfdc uses jquery.ajax
        });
    });

}

function AccountViewCtrl($scope, AngularForce, $location, $routeParams, Account) {

    AngularForce.login(function () {
        Account.get({id: $routeParams.accountId}, function (account) {
            self.original = account;
            $scope.account = new Account(self.original);
            $scope.$apply();//Required coz sfdc uses jquery.ajax
        });
    });

}

function ContactDetailCtrl($scope, AngularForce, $location, $routeParams, Contact) {
    var self = this;

    if ($routeParams.contactId) {
        AngularForce.login(function () {
            Contact.get({id: $routeParams.contactId}, function (contact) {
                self.original = contact;
                $scope.contact = new Contact(self.original);
                $scope.$apply();//Required coz sfdc uses jquery.ajax
            });
        });
    } else {
        $scope.contact = new Contact();
        //$scope.$apply();
    }

    $scope.isClean = function () {
        return angular.equals(self.original, $scope.contact);
    }

    $scope.destroy = function () {
        self.original.destroy(
            function () {
                $scope.$apply(function () {
                    $location.path('/contacts');
                });
            },
            function(errors) {
                alert("Could not delete contact!\n" + JSON.parse(errors.responseText)[0].message);
            }
        );
    };

    $scope.save = function () {
        if ($scope.contact.Id) {
            $scope.contact.update(function () {
                $scope.$apply(function () {
                    $location.path('/view/' + $scope.contact.Id);
                });

            });
        } else {
            Contact.save($scope.contact, function (contact) {
                var p = contact;
                $scope.$apply(function () {
                    $location.path('/view/' + p.id);
                });
            });
        }
    };

    $scope.doCancel = function () {
        if ($scope.contact.Id) {
            $location.path('/view/' + $scope.contact.Id);
        } else {
            $location.path('/contacts');
        }
    }
}
function AccountDetailCtrl($scope, AngularForce, $location, $routeParams, Account) {
    var self = this;

    if ($routeParams.accountID) {
        AngularForce.login(function () {
            Account.get({id: $routeParams.accountID}, function (account) {
                self.original = account;
                $scope.account = new Account(self.original);
                $scope.$apply();//Required coz sfdc uses jquery.ajax
            });
        });
    } else {
        $scope.account = new Account();
        //$scope.$apply();
    }

    $scope.isClean = function () {
        return angular.equals(self.original, $scope.account);
    }

    $scope.destroy = function () {
        self.original.destroy(
            function () {
                $scope.$apply(function () {
                    $location.path('/accounts');
                });
            },
            function(errors) {
                alert("Could not delete contact!\n" + JSON.parse(errors.responseText)[0].message);
            }
        );
    };

    $scope.save = function () {
        if ($scope.account.Id) {
            $scope.account.update(function () {
                $scope.$apply(function () {
                    $location.path('/view/' + $scope.contact.Id);
                });

            });
        } else {
            Account.save($scope.account, function (account) {
                var p = account;
                $scope.$apply(function () {
                    $location.path('/viewaccountdetail/' + p.id);
                });
            });
        }
    };

    $scope.doCancel = function () {
        if ($scope.account.Id) {
            $location.path('/viewaccountdetail/' + $scope.account.Id);
        } else {
            $location.path('/accounts');
        }
    }
}