import 'package:flutter/material.dart';

class PageLogin extends StatelessWidget {
  PageLogin({super.key});

  TextEditingController txtaccountname = TextEditingController();
  TextEditingController txtpassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng nhập"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: txtaccountname,
                decoration: InputDecoration(
                  hintText: "Tên đăng nhập",
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15,),
              //mật khẩu
              TextField(
                controller: txtaccountname,
                decoration: InputDecoration(
                  hintText: "Mật khẩu",
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              //nút hiển thị mật khẩu
              Row(
                children: [
                  IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.visibility),
                  ),
                  Text("Hiển thị mật khẩu", style: TextStyle(fontSize: 16),),
                ],
              ),
              SizedBox(height: 20,),
              //nút đăng nhập
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              //nút tạo tài khoản mới
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Tạo tài khoản mới",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              //đăng nhập bằng gg
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Tiếp tục với",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(width: 10,),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                        height: 24,
                        width: 24,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              //quên mật khẩu
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Quên mật khẩu?", style: TextStyle(fontSize: 16),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}