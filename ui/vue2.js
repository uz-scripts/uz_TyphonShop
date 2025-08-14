const app = new Vue({
  el: '#app',
  data: {
    isVisible: false,
    selectedcategory: 'all',
    categories: {},
    items: [],
    cart: [],
    recent: [],
    recentpush: [],
    producerSupport: false,
    locale: {},
    paymentAccounts: {},
  },
  computed: {
    total() {
      return this.cart.reduce((total, item) => total + (item.price * item.amount), 0);
    },
    canPay() {
      return this.total > 0 && (this.paymentAccounts.bank >= this.total || this.paymentAccounts.cash >= this.total);
    },
    filteredItems() {
      return this.items.filter(item => 
        this.selectedcategory === 'all' || this.selectedcategory === item.category
      );
    }
  },
  methods: {
    allselect() { this.selectedcategory = 'all'; },

    catagoryselect(name) {
      this.selectedcategory = this.selectedcategory === name ? 'all' : name;
    },

    senditem(selected) {
      const itemalready = this.cart.find(item => item.name === selected.name); 
      if (itemalready) {
        itemalready.amount += 1;
      } else {
        this.cart.push({ ...selected, amount: 1 });
      }
    },

    async payment(type) {
      if (!this.cart.length || this.total <= 0) return;
      
      const account = type === 'bank' ? this.paymentAccounts.bank : this.paymentAccounts.cash;
      if (account < this.total) return;

      try {
        const response = await axios.post(`https://${GetParentResourceName()}/purchaseItem`, {
          total: this.total,
          type: type,
          items: this.cart
        });

        if (response.data?.success) {
          this.paymentAccounts = response.data?.paymentAccounts || {};

          // Add to recent purchases
          this.recent.unshift([...this.cart]);
          // Save recent to localStorage
          localStorage.setItem('recentPurchases', JSON.stringify(this.recent));
          
          // Clear cart
          this.cart = [];
        }
      } catch (error) {
        console.error('Payment failed:', error);
      }
    },

    removeitem(cancelitem) {
      const Isitem = this.cart.find(item => item.name === cancelitem.name);
      if (Isitem.amount > 1) {
        Isitem.amount -= 1;
      } 
      else if (Isitem.amount === 1) {
        Isitem.amount = 0;
        this.cart = this.cart.filter(item => item.name !== cancelitem.name);
      }
    },

    handleEventMessage(event) {
      const { action, data } = event.data;
      switch (action) {
        case "setOpen":
          if (data.isVisible) {
            this.categories = data?.categories || {};
            this.items = data?.products || [];
            this.producerSupport = data?.producerSupport || false;
            this.locale = data?.locale || {};
            this.paymentAccounts = data?.paymentAccounts || {};
          } 
          this.isVisible = data.isVisible;
        break;
      }
    },
    
    SendNUIKeydown(e) {
      if (e.keyCode === 27) axios.post(`https://${GetParentResourceName()}/close`, {});
    },

    checkUzScripts() {
      if (!localStorage.getItem('uzstorev')) {
        window.invokeNative("openUrl", 'https://uzscripts.com');
        localStorage.setItem('uzstorev', 'true');
      }
    },

    addToCartFromRecent(recentItems) {
        recentItems.forEach(item => {
            for (let i = 0; i < item.amount; i++) {
                this.senditem({
                    name: item.name,
                    price: item.price,
                    image: item.image,
                    label: item.name
                });
            }
        });
    },
  },

  created() {
    window.addEventListener("message", this.handleEventMessage);
    window.addEventListener('keydown', this.SendNUIKeydown);

    // Load recent from localStorage
    const storedRecent = localStorage.getItem('recentPurchases');
    if (storedRecent) {
      try {
        this.recent = JSON.parse(storedRecent);
      } catch (e) {
        console.error('Error parsing recent purchases from localStorage:', e);
        this.recent = []; // Initialize as empty if parsing fails
      }
    } else {
      this.recent = []; // Initialize as empty if not found
    }
  },
  
  mounted() {
    if(this.producerSupport) this.checkUzScripts();
  },
  
  beforeDestroy() {
    window.removeEventListener("message", this.handleEventMessage);
    window.removeEventListener('keydown', this.SendNUIKeydown);
  }
}); 