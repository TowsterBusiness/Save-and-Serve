from CompletedRequests import recipieMaker

worker = recipieMaker()
imageURL = worker.getImageURL("apple food")
print(imageURL)