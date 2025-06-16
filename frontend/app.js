// Initialize Flagsmith with the JavaScript client
const flagsmithOptions = {
    environmentID: "<YOUR Flagsmith environment ID>",  // Replace with your Flagsmith environment ID
    defaultFlags: {
        progressive_release: false,
        button_color: "primary",
        maintenance_mode: false
    },
    onChange: (oldFlags, params) => {
        // This function is called when flags are updated
        console.log("Flags have been updated");
        updateUI();
    }
};

// Initialize Flagsmith
flagsmith.init(flagsmithOptions).then(() => {
    console.log("Flagsmith initialized successfully");
    
    // 為每個使用者生成一個唯一ID並保存在localStorage中
    let userId = localStorage.getItem('flagsmith_user_id');
    if (!userId) {
        userId = 'user_' + Math.random().toString(36).substring(2, 15);
        localStorage.setItem('flagsmith_user_id', userId);
    }
    
    // 識別使用者
    flagsmith.identify(userId);
    flagsmith.setTrait("is_vip", true)
    console.log("User identified with ID:", userId);
    
    // 然後更新UI
    updateUI();
    setupEventListeners();
}).catch(error => {
    console.error("Failed to initialize Flagsmith:", error);
    // Still setup UI with default values
    updateUI();
    setupEventListeners();
});

let clicks = 0;

// Function to update UI based on feature flags
function updateUI() {
    // Progressive release example
    if (flagsmith.hasFeature("progressive_release")) {
        document.getElementById("progressive-release").classList.remove("d-none");
    } else {
        document.getElementById("progressive-release").classList.add("d-none");
    }
    
    // A/B testing example
    const button = document.getElementById("ab-test-button");
    const buttonColor = flagsmith.getValue("button_color") || "primary";
    console.log("Current button color from Flagsmith:", buttonColor);
    
    // Remove all btn-* classes first
    button.className = button.className.replace(/btn-\w+/g, "").trim();
    // Make sure the base btn class exists
    if (!button.classList.contains("btn")) {
        button.classList.add("btn");
    }
    if (!button.classList.contains("btn-lg")) {
        button.classList.add("btn-lg");
    }
    // Add the new button class
    button.classList.add(`btn-${buttonColor}`);
    
    // Maintenance mode example
    if (flagsmith.hasFeature("maintenance_mode")) {
        document.getElementById("maintenance-mode").classList.remove("d-none");
    } else {
        document.getElementById("maintenance-mode").classList.add("d-none");
    }
    
    // VIP feature example
    if (flagsmith.hasFeature("vip_feature")) {
        document.getElementById("vip-feature").classList.remove("d-none");
    } else {
        document.getElementById("vip-feature").classList.add("d-none");
    }
}

// Setup event listeners
function setupEventListeners() {
    const button = document.getElementById("ab-test-button");
    button.addEventListener("click", () => {
        clicks++;
        document.getElementById("click-counter").textContent = `點擊次數: ${clicks}`;
        
        // Log analytics data
        console.log("Button clicked. Color:", flagsmith.getValue("button_color"), "Total clicks:", clicks);
        
        // Track event with Flagsmith
        flagsmith.trackEvent("button_clicked", {
            buttonColor: flagsmith.getValue("button_color"),
            clickCount: clicks
        });
    });
}

// Optional: Manually refresh flags
// You can call this function to refresh flags at any time
function refreshFlags() {
    flagsmith.getFlags().then(() => {
        console.log("Flags refreshed");
        updateUI();
    }).catch(error => {
        console.error("Failed to refresh flags:", error);
    });
}

// Optional: Set up polling to refresh flags periodically
// setInterval(() => {
//     refreshFlags();
// }, 30000); // Refresh every 30 seconds
