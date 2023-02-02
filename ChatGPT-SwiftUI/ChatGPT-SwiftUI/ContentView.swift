//
//  ContentView.swift
//  ChatGPT-SwiftUI
//
//  Created by Eren Aşkın on 1.02.2023.
//


//Bu, metin girişlerine yanıt vermek için OpenAI'nin dil modelini kullanan bir sohbet arayüzü için SwiftUI kodudur. Kod, OpenAISwift istemcisini bir kimlik doğrulama belirteci ile ayarlayan ve modele metin göndermek ve bir yanıt almak için bir işlev sağlayan "ViewModel" adlı bir sınıf oluşturur. Yanıt daha sonra tamamlama işleyicisine bir dize olarak geri iletilir.

//"ContentView" yapısı, ViewModel'i gözlemlenen bir nesne olarak kullanarak sohbet uygulaması için kullanıcı arayüzünü tanımlar. Kullanıcının metin girmesi için bir metin alanı ve metni modele göndermek için bir düğme içerir. Modelden gelen yanıt bir listede görüntülenir. Arayüz, DispatchQueue.main.async kullanılarak en son yanıtlarla güncellenir.




import SwiftUI
import OpenAISwift

final class ViewModel : ObservableObject {
    
    init(){}
    
    private var client : OpenAISwift?
    
    func setup(){
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text:String,completion:@escaping(String) -> Void ){
        client?.sendCompletion(with: text,maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    var body: some View {
        VStack(alignment: .leading){
            ForEach(models,id: \.self){ string in
                Text(string)
            }
            Spacer()
            HStack{
                TextField("Type here...", text: $text)
                Button("Send"){
                    send()
                }
            }
        }
        .onAppear(){
            viewModel.setup()
        }
        .padding()
    }
    func send(){
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        models.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("ChatGPT: "+response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
