import json
import io
from fractions import Fraction
import requests
from PIL import Image
import json
import os
from serpapi import GoogleSearch
from vertexai.generative_models import Part

class superAccurateRecipieMaker():
    
    def __init__(self, model):
        
        self.model = model
        
        self.headers = {"Content-Type": "application/json"}
        self.default_params = {"apiKey": "65ed94ce760342f5bdb12f4757f2db94"} # os.getenv("SPOONACULAR_KEY")} TODO

    def image_to_text(self, imageInBytes: bytes):
        
        prompt = """What items can you find in this fridge? List them in a comma separated list, and state your confidence in each item you identify (0-1).
            Do not give extra details, provide simple ingredients (Do not care for brands or types of items, just the item name). 
            For example, the following would work: Apple-1.0, Carrots-.9, Ranch Dressing-.8, Milk-.7, Eggs-.75, Bread-.8, etc. 
            Every item you mention should be buyable from a grocery store. For example, do not look for leftovers or specific meals."""
        
        image_part = Part.from_data(
            data=imageInBytes,
            mime_type="image/jpeg"
        )
        
        contents = [prompt, image_part]

        print("Sending request to Vertex AI... (This may take a moment)")
        
        response = self.model.generate_content(contents)
        
        print(response.text)
        
        return response.text
    
    def text_to_text(self,text):
        prompt = f"""Here is a list of ingridents found in a fridge, with their corresponding confidence scores (0-1, meaning how confident we are in each item actually being there) {text}. 
        After analyzing the ingredients and their values, remove ingridents that sound the exact same (ex milk and whole milk would translate to whole milk).
        Return the final list of ingridients with this change in a comma seperated list (Respond to this prompt with a comma seperated list of the final ingridients). 
        Lastly, remember that the output should only be ingridients, no objects like refrigator, jars, containers, or vauge descripions like condiments."""

        contents = [prompt]
        
        print("Sending request to Vertex AI... (This may take a moment)")
        
        response = self.model.generate_content(contents)
        
        print(response.text)
        
        return response.text
    
    def processBinaryImage(self, imageInBinary = None):
        if isinstance(imageInBinary, (bytes, bytearray)):
            img = Image.open(io.BytesIO(imageInBinary))
        elif hasattr(imageInBinary, 'read'):
            img = Image.open(imageInBinary)
        elif isinstance(imageInBinary, str):
            img = Image.open(imageInBinary)
        else:
            raise ValueError("Unsupported type for imageInBinary")
        
        # Step 2: Convert to bytes
        with io.BytesIO() as output:
            # Ensure RGB mode if needed (avoids issues with some formats)
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            img.save(output, format="JPEG")
            return output.getvalue()
        
    def getRecipiesMatchingIngridents(self):
        self.outputJSON = []
        
        for recipe in self.recipiesAPIFOUND:
            recipeData = {}
            
            id = recipe['id']
            title = recipe['title']
            image = recipe['image']
            missedIngredients = recipe['missedIngredientCount']

            usedIngredients = recipe['usedIngredients']
            ingridentsList = []
            for ingrident in usedIngredients:
                ofIncluded = " of "
                amount = ingrident['amount']

                if ingrident['unitLong'] == "":
                    ofIncluded = ""
                    
                    #Check for decimals below 1, and replace with fractions
                    if ingrident['amount'] < 1:
                        # Convert to fraction
                        fraction = Fraction(ingrident['amount']).limit_denominator()
                        amount = f"{fraction.numerator}/{fraction.denominator}"

                ingridentsList.append(f"{amount} {ingrident['unitLong']}{ofIncluded}{ingrident['name']}")

            recipeData["GeneralInfo"] = {
                "id": id,
                "title": title,
                "image": image,
                "missedIngredients": missedIngredients,
                "usedIngredients": ingridentsList
            }
            
            self.outputJSON.append(recipeData)

    
    def getSpecificsOnRecipies(self):
        for recipe in self.outputJSON:
            id = recipe["GeneralInfo"]["id"]
            print(recipe)
            
            # Get instructions
            instructions = requests.get(f"https://api.spoonacular.com/recipes/{id}/analyzedInstructions",  headers = self.headers, params={"stepBreakdown":True,**self.default_params}).json()
            if instructions == []:
                recipe["instructions"] = []
            else:
                # print("__________________\n\n\n" , instructions)
                steps = instructions[0]["steps"]
                # print(steps)
                recipe["instructions"] = [step["step"] for step in steps]
                # print([step["step"] for step in steps])

            # Get nutrition
            nutrition = requests.get(f"https://api.spoonacular.com/recipes/{id}/nutritionWidget.json",  headers = self.headers, params={**self.default_params}).json()
            recipe["nutrition"] = {
                "calories": nutrition["calories"],
                "fat": nutrition["fat"],
                "protein": nutrition["protein"],
                "carbohydrates": nutrition["carbs"]
            }

            # Get price
            price_data = requests.get(f"https://api.spoonacular.com/recipes/{id}/priceBreakdownWidget.json",  headers = self.headers, params={**self.default_params}).json()
            recipe["price"] = price_data["totalCost"]/100

        print(json.dumps(self.outputJSON, indent=4))
    
    def getIngridents(self, imageInBinary = None):
        image = self.processBinaryImage(imageInBinary)
        print("Image Processed")

        # ingredients = "chicken breast, ground beef, eggs, tofu, canned tuna, chickpeas, bacon, rice, pasta, bread, tortillas, potatoes, quinoa, onions, garlic, bell peppers, carrots, spinach, tomatoes, broccoli, apples, bananas, lemons, avocados, cheese, milk, olive oil, salt, black pepper, paprika"

        ingredients = self.image_to_text(image)
        
        return ingredients
    
    # def getRecipies(self, imageInBinary = None):
    #     image = self.processBinaryImage(imageInBinary)
    #     print("Image Processed")

    #     # ingredients = "chicken breast, ground beef, eggs, tofu, canned tuna, chickpeas, bacon, rice, pasta, bread, tortillas, potatoes, quinoa, onions, garlic, bell peppers, carrots, spinach, tomatoes, broccoli, apples, bananas, lemons, avocados, cheese, milk, olive oil, salt, black pepper, paprika"

    #     ingredients = self.image_to_text(image)

    #     # ingredients = "Ketchup, Jam, Mustard, Salad Dressing, Salsa, Milk, Yogurt, Bagels, Grapes, Strawberries, Blueberries, Lettuce, Tomatoes, Peppers, Eggs, Cheese, Tofu, Chocolate Syrup, Hummus, Chips, Butter, Orange Juice, Water Bottles"
    #     print(f"Ingredients are: {ingredients}")
        
    #     ingredientsparams ={
    #         "ingredients":ingredients,
    #         "number":2,
    #         "ranking":2,
    #         "ignorePantry":True,
    #         **self.default_params
    #     }

    #     self.recipiesAPIFOUND = requests.get(f"https://api.spoonacular.com/recipes/findByIngredients",  headers = self.headers, params=ingredientsparams).json()
        
        
    #     self.getRecipiesMatchingIngridents()
    #     self.getSpecificsOnRecipies()
    #     # self.replaceImageWithURL()
    
    
    def getRecipies(self, ingridents):
        print("Unprocessed ingridents:", ingridents)
        processedIngridents = self.text_to_text(ingridents)
        print(f"Processed Ingredients are: {processedIngridents}")
        
        ingredientsparams ={
            "ingredients":processedIngridents,
            "number":5,
            "ranking":2,
            "ignorePantry":True,
            **self.default_params
        }

        self.recipiesAPIFOUND = requests.get(f"https://api.spoonacular.com/recipes/findByIngredients",  headers = self.headers, params=ingredientsparams).json()
        
        
        self.getRecipiesMatchingIngridents()
        self.getSpecificsOnRecipies()
        # self.replaceImageWithURL()    
    
    def replaceImageWithURL(self):
        
        for i, recipie in enumerate(self.outputJSON):
            title = recipie["GeneralInfo"]["title"]
            imageURL = self.getImageURL(title + " food")
            if imageURL:
                self.outputJSON[i]["GeneralInfo"]["image"] = imageURL
        
    def getImageURL(self, query):
        params = {
            "engine": "google_images_light",
            "q": query, 
            "api_key": os.getenv("SERPAPI_KEY")
        }

        search = GoogleSearch(params)
        results = search.get_dict()
        
        images_results = results.get("images_results", [])
        if images_results:
            return images_results[0].get("original")  # first image URL
        return None
        
# imageList = []
# imageList.append(open("Images/IMG_9248.JPG", "rb").read())
# imageList.append(open("Images/IMG_9249.JPG", "rb").read())
# imageList.append(open("Images/IMG_9250.JPG", "rb").read())
# imageList.append(open("Images/IMG_9251.JPG", "rb").read())
# imageList.append(open("Images/IMG_9252.JPG", "rb").read())
# imageList.append(open("Images/IMG_9253.JPG", "rb").read())
# imageList.append(open("Images/IMG_9254.JPG", "rb").read())
# imageList.append(open("Images/IMG_9255.JPG", "rb").read())
# imageList.append(open("Images/IMG_9256.JPG", "rb").read())
# imageList.append(open("Images/IMG_9257.JPG", "rb").read())


# worker = superAccurateRecipieMaker(model)
# unprocessedIngridents = []
# for image in imageList:
#     unprocessedIngridents.append(worker.getIngridents(image))

# print(unprocessedIngridents)

# response = worker.getRecipies(unprocessedIngridents)
# print(response)